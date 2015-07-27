module(...,package.seeall)

local backend = require('pf.backend')

local relop_map = {
   ['<']='<', ['<=']='<=', ['=']='==', ['!=']='~=', ['>=']='>=', ['>']='>'
}

local vars = {}

local function read_buffer_word_by_type(P, offset, size)
   if size == 1 then
      return P[offset]
   elseif size == 2 then
      return terralib.cast(&uint16, P+offset)[0]
   elseif size == 4 then
      return terralib.cast(&uint32, P+offset)[0]
   else
      error("bad [] size: "..size)
   end
end

local inet = terralib.includec 'netinet/in.h'
local cdefs = terralib.includecstring [[
#include "stdint.h"
inline uint32_t cdiv(uint32_t a, uint32_t b)    { return a / b; }
inline uint32_t cand(uint32_t a, uint32_t b)    { return a & b; }
inline uint32_t cxor(uint32_t a, uint32_t b)    { return a ^ b; }
inline uint32_t cor(uint32_t a, uint32_t b)     { return a | b; }
inline uint32_t clshift(uint32_t a, uint32_t b) { return a << b; }
inline uint32_t crshift(uint32_t a, uint32_t b) { return a >> b; }
inline uint32_t clookup(int8_t *P, uint32_t offset, uint32_t size) {
   if (size == 1) { return (uint32_t)(P[offset]); }
   if (size == 2) { return (uint32_t)(((uint16_t*)(P+offset))[0]); }
   return (uint32_t)(((uint32_t*)(P+offset))[0]);
}
]]

local function serialize_value (P, len, expr)
   if expr == 'len' then return `len end
   if type(expr) == 'number' then return `expr end
   if type(expr) == 'string' then return vars[expr] end
   assert(type(expr) == 'table')
   local op, lhs = expr[1], serialize_value(P, len, expr[2])
   if op == 'ntohs' then return `inet.ntohs([ lhs ])
   elseif op == 'ntohl' then return `inet.ntohl([ lhs ])
   elseif op == 'int32' then return lhs
   elseif op == 'uint32' then return `[ lhs ] % 2^32
   end
   local rhs = serialize_value(P, len, expr[3])
   if op == '[]' then
      return `cdefs.clookup(P, [ lhs ], [ rhs ])
   elseif op == '+' then return `[ lhs ] + [ rhs ]
   elseif op == '-' then return `[ lhs ] - [ rhs ]
   elseif op == '*' then return `[ lhs ] * [ rhs ]
   elseif op == '/' then return `cdefs.cdiv([ lhs ], [ rhs ])
   elseif op == '&' then return `cdefs.cand([ lhs ], [ rhs ])
   elseif op == '^' then return `cdefs.cxor([ lhs ], [ rhs ])
   elseif op == '|' then return `cdefs.cor([ lhs ], [ rhs ])
   elseif op == '<<' then return `cdefs.clshift([ lhs ], [ rhs ])
   else
      assert(op == '>>')
      return `cdefs.crshift([ lhs ], [ rhs ])
   end
end

local function serialize_bool(P, len, expr)
   local op = expr[1]
   if op == 'true' then return `true
   elseif op == 'false' then return `false
   elseif relop_map[op] then
      -- An arithmetic relop.
      local op = relop_map[op]
      local lhs, rhs = serialize_value(P, len, expr[2]), serialize_value(P, len, expr[3])
      return `operator(op, [ lhs ], [ rhs ])
   else
      error('unhandled primitive'..op)
   end
end

local serialize_statement

local function serialize_sequence (P, len, stmts)
   if stmts[1] == 'do' then
      local code = terralib.newlist()
      for i=2,#stmts do code:insert(serialize_statement(P, len, stmts[i], i==#stmts)) end
      return code
   else
      return serialize_statement(P, len, stmts, true)
   end
end

local function serialize_call(P, len, expr)
   local args = terralib.newlist()
   for i=3,#expr do args:insert(serialize_value(P, len, expr[i])) end
   -- return 'self.'..expr[2]..'('..table.concat(args, ', ')..')'
   return quote
      [ expr[2] ]([ P ], [ len ], table.unpack([ args ]))
   end
end

function serialize_statement (P, len, stmt, is_last)
   local op = stmt[1]
   if op == 'do' then
      return quote do [ serialize_sequence(P, len, stmt) ] end end
   elseif op == 'return' then
      if not is_last then
         return serialize_statement(P, len, { 'do', stmt }, false)
      end
      if stmt[2][1] == 'call' then
         return serialize_call(P, len, stmt[2])
      else
         return quote return [ serialize_bool(P, len, stmt[2]) ] end
      end
   elseif op == 'goto' then
      return quote goto [ stmt[2] ] end
   elseif op == 'if' then
      local test, t, f = stmt[2], stmt[3], stmt[4]
      test = serialize_bool(P, len, test)
      if backend.is_simple_expr(t) then
         if t[1] == 'return' then
            local result
            if t[2][1] == 'call' then
               result = serialize_call(P, len, t[2])
            else
               result = serialize_bool(P, len, t[2])
            end
            return quote
               if [ test ] then return [ result ] end
            end
         else
            assert(t[1] == 'goto')
            return quote
               if [ test ] then goto [ t[2] ] end
            end
         end
         if f then serialize_statement(P, len, f, is_last) end
      else
         if f then
            return quote
               if [ test ] then
                  [ serialize_sequence(P, len, t) ]
               else 
                  [ serialize_sequence(P, len, f) ]
               end
            end
         else
            return quote
               if [ test ] then [ serialize_sequence(P, len, t) ] end
            end
         end
      end
   elseif op == 'bind' then
      local name, expr = stmt[2], stmt[3]
      local x = symbol(name)
      vars[name] = x
      return quote
         var [x] = [ serialize_value(P, len, expr) ]
      end
   else
      assert(op == 'label')
      return quote
         :: [ stmt[2] ] ::
         [ serialize_statement(P, len, stmt[3], is_last) ]
      end
   end
end

function generate_filter (ssa)
   local P = symbol('P')
   local len = symbol('len')
   local ssa = backend.cleanup(backend.residualize_lua(ssa), true)
   return terra ([P] : rawstring, [len] : uint32)
      [ serialize_sequence(P, len, ssa) ]
   end
end

function selftest()
   print("selftest: pf.terra")
   local parse = require('pf.parse').parse
   local expand = require('pf.expand').expand
   local optimize = require('pf.optimize').optimize
   local convert_anf = require('pf.anf').convert_anf
   local ssa = require('pf.ssa')

   local function test(expr)
      local ast = ssa.optimize_ssa(ssa.lower(convert_anf(optimize(expand(parse(expr), "EN10MB")))))
      ssa.order_blocks(ast)
      -- ast = stratify_blocks(ast)
      -- print(serialize(ast, expr):disas())
      -- serialize(ast, expr):disas()
      print(generate_filter(ast):disas())
   end

   test("tcp port 80 or udp port 34")
   print("OK")
end

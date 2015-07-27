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

local function serialize_value (expr, P, len)
   if expr == 'len' then return `len end
   if type(expr) == 'number' then return `expr end
   if type(expr) == 'string' then return vars[expr] end
   assert(type(expr) == 'table')
   local op, lhs = expr[1], serialize_value(expr[2], P, len)
   if op == 'ntohs' then return `inet.ntohs([ lhs ])
   elseif op == 'ntohl' then return `inet.ntohl([ lhs ])
   elseif op == 'int32' then return lhs
   elseif op == 'uint32' then return `[ lhs ] % 2^32
   end
   local rhs = serialize_value(expr[3], P, len)
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

local function serialize_bool(expr, P, len)
   local op = expr[1]
   if op == 'true' then return `true
   elseif op == 'false' then return `false
   elseif relop_map[op] then
      -- An arithmetic relop.
      local op = relop_map[op]
      local lhs, rhs = serialize_value(expr[2], P, len), serialize_value(expr[3], P, len)
      return `operator(op, [ lhs ], [ rhs ])
   else
      error('unhandled primitive'..op)
   end
end

local function serialize_control (control, P, len)
   if control[1] == 'goto' then
      return quote goto [ control[2] ] end
   elseif control[1] == 'return' then
      return quote return [ serialize_bool(control[2], P, len) ] end
   else
      assert(control[1] == 'if')
      return quote
         if [ serialize_bool(control[2], P, len) ] then
            goto [ control[3] ]
         else
            goto [ control[4] ]
         end
      end
   end
end

local function serialize_bindings(bindings, P, len)
   local bindings_code = terralib.newlist()
   for _,binding in ipairs(bindings) do
      local name = binding.name
      local expr = binding.value
      local x = symbol(name)
      vars[name] = x
      bindings_code:insert(quote
         var [x] = [ serialize_value(expr, P, len) ]
      end)
   end
   return `bindings_code
end

function generate_filter (ssa)
   local P = symbol('P')
   local len = symbol('len')
   local blocks = terralib.newlist()
   for _,label in ipairs(ssa.order) do
      local block = ssa.blocks[label]
      blocks:insert(quote
         :: [ label ] ::
         [ serialize_bindings(block.bindings, P, len) ]
         [ serialize_control(block.control, P, len) ]
      end)
   end
   return terra ([P] : rawstring, [len] : uint32)
      [ blocks ]
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

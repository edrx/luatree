# This file:
#   http://angg.twu.net/luatree/luatree.py.html
#   http://angg.twu.net/luatree/luatree.py
#           (find-angg "luatree/luatree.py")
# Author: Eduardo Ochs <eduardoochs@gmail.com>
#
# (defun m  () (interactive) (find-angg "luatree/luatree.mac"))
# (defun li () (interactive) (find-angg "luatree/luatree.lisp"))
# (defun lu () (interactive) (find-angg "luatree/luatree.lua"))
# (defun p  () (interactive) (find-angg "luatree/luatree.py"))
#
# (find-es "python" "luatree")

import pathlib
import subprocess
luatree_dir    = pathlib.Path(__file__).parent
luatree_script = luatree_dir / "luatree.lua"

from sympy import Function, Symbol, AtomicExpr

def luatree_lua(str):
    p = subprocess.run(luatree_script, input=str, stdout=subprocess.PIPE, text=True)
    return p.stdout

def luatree1d(o):
    if isatom(o):
        return luatree1(o)
    else:
        return luatreeopargs(o)

isatom_py       = lambda o: isinstance(o, int) or isinstance(o, str)
isatom_sympy    = lambda o: isinstance(o, AtomicExpr)
isatom          = lambda o: isatom_py(o) or isatom_sympy(o)
luatreefunc     = lambda o: o.func.__name__
luatree1        = lambda o:     '"' + str(o) + '"'
luatreeop       = lambda s: '[0]="' + s + '"'
luatreearg      = lambda s: ', ' + s
luatreeargs     = lambda L: ''.join(list(map(luatreearg, L)))
luatreeopargs2  = lambda s,L: '{' + luatreeop(s) + luatreeargs(L) + '}'
luatreeopargs   = lambda o: luatreeopargs2(luatreefunc(o), list(map(luatree1d, o.args)))
luatree         = lambda o: print(luatree_lua(luatree1d(o)))

"""
 (eepitch-isympy)
 (eepitch-kill)
 (eepitch-isympy)
import sys
sys.path[1:1] = ["/home/edrx/luatree"]
from luatree import *

from sympy import Function, Symbol, dsolve
f   = Function('f')
x   = Symbol('x')
od  = f(x).diff(x, x) + f(x)
foo = x ** x + 42
od, foo

luatree(foo)
luatree(od)

luatreeopargs2("Pow", list(map(str, [x, x])))
luatreeopargs2("Pow", list(map(luatree1, [x, x])))
luatreeopargs(x ** x)
luatree1d(x)
luatree1d(x ** x)
luatree1d(x + x ** x)
luatree  (x + x ** x)
luatree  (x + x ** 42)
luatree  (f(x))
luatree  (od)

"""




# Local Variables:
# coding:  utf-8-unix
# End:

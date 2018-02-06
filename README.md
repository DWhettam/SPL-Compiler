# SPL-Compiler
---------------------------------------------------------------------------------------------------------------------------------

The zip file contains the following files:  
bnf.txt  
spl.l  
spl.y  
spl.c  
Daniel-results.txt  

---------------------------------------------------------------------------------------------------------------------------------

The SPL language assumes the following:
- NOT conditionals within an if statement apply to the entire conditional 
	(e.g. IF NOT a < 1 AND a > -3 THEN ... ENDIF would be treated as IF NOT (a < 1 AND a > -3) THEN ... ENDIF)

- Statically typed
	- All identifiers must be declared before use

- Strongly typed
	- SPL will not allow any mixing of types, with 2 exceptions. The exceptions are as follows:
		- Addition and subtraction between INTEGER's and REAL's
		- Assignment of an INTEGER to a REAL
	- Consequently, tests 43, 44 and 45 in the additional provided tests will fail.

- When declaring a FOR loop, all expressions must be of type INTEGER

- Variables must be initialised before use

- Variables cannot be declared within a FOR loop, implicitly or explicitly

---------------------------------------------------------------------------------------------------------------------------------

The SPL Compiler makes the following optimisations:
- If adding a value of 0 (e.g. 3 + 0) the 0 is removed as it is irrelevant
- If subtracting a value of 0 (e.g. 3 - 0) the 0 is removed as it is irrelevant
- If multiplying by 0 (e.g. 3 * 0) the expression is resolved to 0
- If multiplying by 1 (e.g. 3 * 1) the 1 is removed as it is irrelevant
- If dividing by 1 (e.g. 3 / 1) the 1 is removed as it is irrelevant
- If dividing with a numerator of 0 (e.g. 0 / 3) the expression is resolved to 0


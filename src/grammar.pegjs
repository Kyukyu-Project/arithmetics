{
  function evaluate(terms) {
    /** replace 3 terms with one new term */
    const replaceTerm = (replaceAt, newTerm) => {
      terms[replaceAt] = newTerm; // replace one term
      terms.splice(replaceAt + 1, 2); // remove next two items
    }
    /** find first exponentitation operator */
    const findOp1 = () => terms.findIndex((t) => t.value === '^');

    /** find first addition or subtraction operator */
    const findOp2 = () => terms.findIndex((t) => t.value === '*' || t.value === '/');

    /** find first multiplication or division operator */
    const findOp3 = () => terms.findIndex((t) => t.value === '+' || t.value === '-');

    let operatorIdx;
    let operator;
    let left;
    let right;

    // -------------------- First, calculate exponents --------------------
    operatorIdx = findOp1();
    while (operatorIdx !== -1) {
      // Return an error if there is serial exponentiation (a^b^c)
      if (terms.length >= (operatorIdx + 4)) {
        if (terms[operatorIdx + 2].value === '^') {
          return error('Serial exponentitation (a^b^c) is ambiguous. Please rewrite your equation.');
        }
      }
      left  = terms[operatorIdx - 1].value;
      right = terms[operatorIdx + 1].value;
      replaceTerm(
        operatorIdx - 1,
        {type: 'calculated', value: Math.pow(left, right)},
      );
      operatorIdx = findOp1();
    }

    // ------------ Next, calculate multiplication and division ------------
    operatorIdx = findOp2();
    while (operatorIdx !== -1) {
      operator = terms[operatorIdx].value;
      // Return an error if there is chained division (a/b/c)
      if ((operator === '/') && (terms.length >= (operatorIdx + 4))) {
        if (terms[operatorIdx + 2].value === '/') {
          return error('Chained division (a/b/c) is ambiguous. Please rewrite your equation.');
        }
      }
      left  = terms[operatorIdx - 1].value;
      right = terms[operatorIdx + 1].value;
      replaceTerm(
        operatorIdx - 1,
        {type: 'calculated', value: (operator === '*')?(left * right):(left / right)},
      );
      operatorIdx = findOp2();
    }

    // ----------- Finally, calculate addition and substraction -----------
    operatorIdx = findOp3();
    while (operatorIdx !== -1) {
      operator = terms[operatorIdx].value;
      left  = terms[operatorIdx - 1].value;
      right = terms[operatorIdx + 1].value;
      replaceTerm(
        operatorIdx - 1,
        {type: 'calculated', value: (operator === '+')?(left + right):(left - right)},
      );
      operatorIdx = findOp3();
    }
    
    return terms[0].value;
  }

  function evaluateFunction(fn, p) {
    fn = fn.toLowerCase();
    switch (fn) {
      case 'sqrt': return Math.sqrt(p[0]);
      case 'max': return Math.max(...p);
      case 'min': return Math.min(...p);
      case 'floor': return Math.floor(p[0]);
      case 'ceiling': return Math.ceil(p[0]);
      case 'round':
        const multiplier = p[1]?Math.pow(10, p[1]):1;
        return Math.round(p[0] * multiplier) / multiplier;
      case 'sum': return p.reduce((s, v) => s + v, 0);
      case 'average': return p.reduce((s, v) => s + v, 0) / p.length;
      case 'power': return (p.length >= 2)?(Math.pow(p[0], p[1])):NaN;
      case 'log': return Math.log(p[0]) / Math.log( (p.length >= 2)?p[1]:10);
      case 'ln': return Math.log(p[0]);
      case 'abs': return Math.abs(p[0]);
    }
  }
}

Main
  = expr:Expression __ EOF {
    return expr.value;
  }

Expression
  // = head:Term tails:(__ @Operator __ @(Term/ImplicitTail))* __ {
  = __ head:Term tails:(__ @Operator __ @Term)* __ {
    const terms = tails.flat();
    terms.unshift(head);
    return {
      type: 'calculated',
      value: evaluate(terms),
    };
  }

// Implicit multiplication (e.g. 2(2+1) )
// Not implemented because it can lead to ambiguity
// ImplicitTail
//   = __ term:(ParentheticExpression) {
//     return [
//       {
//         type: 'implicit',
//         value: '*',
//       },
//       term,
//     ]
//   }

Term
  = sign:'-'? term:(Number / Constant / ParentheticExpression / Function)
  {
    if (sign === '-') {
      term.value = -term.value;
      return term;
    } else {
      return term;
    }
  }
  
Operator 'operator'
  = op:[-+*/^] {
    return {
      type: 'operator',
      value: op,
    };
  }

ParentheticExpression "parenthetic expression"
  = "(" __ @Expression __ ")"

Number "number"
  = Rational
  / Integer

Integer
  = [1-9][0-9]*
  {
    const value = parseInt(text(), 10);
    return { type: 'number', value: value };
  }

Rational
  = int:$([1-9][0-9]*) '.' dec:$([0-9]+)
  {
    const integerPart = parseInt(int, 10);
    const decimalPart = (parseInt(dec, 10) / Math.pow(10, dec.length));
    const value = integerPart + decimalPart;
    return { type: 'number', value: value };
  }

Constant "constant"
  = 'pi'i !Alphanumerical
  {
    return { type: 'constant', value: Math.PI };
  }
  / 'e'i !Alphanumerical
  {
    return { type: 'constant', value: Math.E };
  }

Function 'function'
  = fn:FunctionName __ '(' p:Parameters? __ ')'
  {
    if (p === null) return error('missing parameter');
    return {
      type: 'calculated',
      value: evaluateFunction(fn, p)
    }
  }

ConstantName
  = 'pi'i
  / 'e'i

FunctionName
  = 'sqrt'i
  / 'max'i
  / 'min'i
  / 'floor'i
  / 'ceiling'i
  / 'round'i
  / 'sum'i
  / 'average'i
  / 'power'i
  / 'log'i
  / 'ln'i
  / 'abs'i

Parameters 'parameters'
  = head:Expression tails:( __ ',' __ @Expression)*
  {
    tails.unshift(head);
    return tails.map((term) => term.value);
  }

Digit "digit"
  = [0-9]

Alphanumerical "Alphanumerical"
  = [0-9a-zA-Z]

__ "white space"
  = [ \t\n\r]*

EOF "end of file"
  = !.

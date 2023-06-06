import {parse} from './arithmetic-parser.js';
const {stdout} = process;

const CD  = '\x1b[2;37m'; // Gray
const CG  = '\x1b[1;32m'; // Bright green
const CY  = '\x1b[1;33m'; // Bright yellow
const CX  = '\x1b[0m';    // Reset

process.stdin.on('data', (expression) => {
  expression = expression.toString().trimEnd();
  if (expression === '') process.exit(0);
  let answer;
  try {
    const result = parse(expression);
    if (Number.isNaN(result)) answer = 'NaN';
    else if (result === Number.NEGATIVE_INFINITY) answer = '-Infinity';
    else if (result === Number.POSITIVE_INFINITY) answer = 'Infinity';
    else if (Number.isInteger(result)) answer = result.toString();
    else answer = (Math.round(result * 1000000000, 9)/1000000000).toString();
  } catch (e) {
    answer = 'Error';
  }
  expression = expression.padEnd(57);
  answer = answer.padStart(20);

  stdout.moveCursor(0, -1);
  stdout.clearLine(1);
  stdout.cursorTo(0);
  stdout.write(`${CD}> ${expression}${CX}${CG}${answer}${CX}\n`);
  stdout.write(`${CY}> ${CX}`);
});

stdout.write(`
======================== Simple Arithmetic Calculator ========================

Type in an arithmetic expression
`);
stdout.write(`${CY}> ${CX}`);

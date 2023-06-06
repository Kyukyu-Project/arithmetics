Simple Arithmetic Parser
======================

A arithmetic parser written in JavaScript, generated with PEG grammar.

## Build

To build, run

```bash
npm install
npm run build
```

## Command-line interface

To use the command-line interface, run

```bash
npm run cli
```
![Command-line interface](/images/cli.png)


## Supported Syntax

The parser supports basic arithmetics operations (`+ - * / ^`)
and some common functions:
- `sqrt`
- `max`, `min`
- `floor`, `ceiling`
- `round`
- `sum`, `average`
- `power`
- `log`, `ln`
- `abs`
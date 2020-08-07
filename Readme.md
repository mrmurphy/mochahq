# RETIRED PROJECT
So sorry, this project is no longer maintained. Let me know if you'd like to take it over!

# Mocha HQ

A pleasant GUI interface for [Mocha](https://mochajs.org/)

![screenshot 2016-04-16 11 31 57](https://cloud.githubusercontent.com/assets/1227109/14582589/eb13f8c4-03c6-11e6-94c8-af02a995e4de.png)

If you don't love:

- Killing mocha and retyping `mocha -w -g "<blah>"` every time you want to change which test set is run
- Killing mocha and changing your '.only' call every time you want to change which test set is run
- Accidentally committing `.only`
- Clearing your terminal before re-running your test suite

You might like MochaHQ

It purposes to beautify and speed up the running of select mocha tests.

MochaHQ, when run in your project directory, will read your mocha.opts file,
and automatically read all mocha tests specified therein.

Those tests will be listed on the left sidebar, and allow you to easily run any of your
suites, or individual tests.

MochaHQ runs mocha in the background in `watch` mode, so your tests should automatically re-run when
you change a file. And the results should be sent to your browser right away.

When you change test suites, (or change the match pattern by hand), the background
Mocha process will be terminated, and a new process will be launched with the new pattern.

# Installation

`npm install -g mochahq`

# Usage

`cd <your project directory>; mochahq`

MochaHQ will begin running, and the address on which it's serving will be
printed to the console.

## Changing the Port

If you want to change the port MochaHQ uses, just set the
`PORT` environment variable:

`PORT=8780 cd <your project directory>; mochahq`

## Keybindings

The following keybindings are available:

```
h (or left arrow) - Display the parent test and its children in the sidebar
j (or down arrow) - Highlight the next test in the sidebar
k (or up arrow) - Highlight the previous test in the sidebar
l (or right arrow) - Display the children of the highlighted test in the sidebar
<enter> - Run the test that's highlighted in the sidebar
shift-j : Scroll the test results down
shift-k : Scroll the test results up
```

## Caveats

MochaHQ is currently only supported in Chrome. Pull requests for support in other
browsers are very welcome.

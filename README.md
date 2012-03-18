HumboldtJS Library
==================

## What is it?

HumboldtJS Library is the standard library to use with HumboldtJS. It is
similar in function to the playerglobal.swc in Flash and provides standard
things like a DisplayObject, a Stage, EventDispatcher and a number of
utility classes to deal with the DOM.

This library is essential when developing HumboldtJS applications.

## What do I do with it?

Usually you will only want the *bin/HumboldtJSLibrary.swc*,
*lib/HumboldtJSDOM.swc* and *dom* folder and drop that into your project.
You can safely ignore the rest of this repository. The rest is only needed
if you want to fix bugs in the standard library or expand the functionality.

## How to build it?

After cloning this repository you can import the folder as an existing project
in Adobe Flash Builder. This may not be needed depending on your usage
scenario. Actually building the library is done by running the ant build
script in the *build* folder.

Note that you may need to update the *FLEX_HOME* path in the ant build.xml
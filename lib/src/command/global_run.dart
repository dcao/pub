// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:path/path.dart' as p;

import '../command.dart';
import '../io.dart';
import '../log.dart' as log;
import '../utils.dart';

/// Handles the `global run` pub command.
class GlobalRunCommand extends PubCommand {
  String get name => "run";
  String get description =>
      "Run an executable from a globally activated package.\n"
      "NOTE: We are currently optimizing this command's startup time.";
  String get invocation => "pub global run <package>:<executable> [args...]";
  bool get allowTrailingOptions => false;

  GlobalRunCommand() {
    argParser.addFlag("checked",
        abbr: "c", help: "Enable runtime type checks and assertions.");
    argParser.addOption("mode", help: "Deprecated option", hide: true);
  }

  Future run() async {
    if (argResults.rest.isEmpty) {
      usageException("Must specify an executable to run.");
    }

    var package;
    var executable = argResults.rest[0];
    if (executable.contains(":")) {
      var parts = split1(executable, ":");
      package = parts[0];
      executable = parts[1];
    } else {
      // If the package name is omitted, use the same name for both.
      package = executable;
    }

    var args = argResults.rest.skip(1).toList();
    if (p.split(executable).length > 1) {
      usageException('Cannot run an executable in a subdirectory of a global '
          'package.');
    }

    if (argResults.wasParsed("mode")) {
      log.warning("The --mode flag is deprecated and has no effect.");
    }

    var exitCode = await globals.runExecutable(package, executable, args,
        checked: argResults["checked"]);
    await flushThenExit(exitCode);
  }
}

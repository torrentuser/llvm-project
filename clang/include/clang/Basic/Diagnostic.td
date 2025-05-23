//===--- Diagnostic.td - C Language Family Diagnostic Handling ------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
//  This file defines the TableGen core definitions for the diagnostics
//  and diagnostic control.
//
//===----------------------------------------------------------------------===//

// See the Internals Manual, section The Diagnostics Subsystem for an overview.

// Define the diagnostic severities.
class Severity<string N> {
  string Name = N;
}
def SEV_Ignored : Severity<"Ignored">;
def SEV_Remark  : Severity<"Remark">;
def SEV_Warning : Severity<"Warning">;
def SEV_Error   : Severity<"Error">;
def SEV_Fatal   : Severity<"Fatal">;

// Define the diagnostic classes.
class DiagClass;
def CLASS_NOTE      : DiagClass;
def CLASS_REMARK    : DiagClass;
def CLASS_WARNING   : DiagClass;
def CLASS_EXTENSION : DiagClass;
def CLASS_ERROR     : DiagClass;

// Responses to a diagnostic in a SFINAE context.
class SFINAEResponse;
def SFINAE_SubstitutionFailure : SFINAEResponse;
def SFINAE_Suppress            : SFINAEResponse;
def SFINAE_Report              : SFINAEResponse;
def SFINAE_AccessControl       : SFINAEResponse;

// Textual substitutions which may be performed on the text of diagnostics
class TextSubstitution<string Text> {
  string Substitution = Text;
  // TODO: These are only here to allow substitutions to be declared inline with
  // diagnostics
  string Component = "";
  string CategoryName = "";
  bit Deferrable = 0;
}

// Diagnostic Categories.  These can be applied to groups or individual
// diagnostics to specify a category.
class DiagCategory<string Name> {
  string CategoryName = Name;
}

// Diagnostic Groups.
class DiagGroup<string Name, list<DiagGroup> subgroups = [], code docs = [{}]> {
  string GroupName = Name;
  list<DiagGroup> SubGroups = subgroups;
  string CategoryName = "";
  code Documentation = docs;
}
class InGroup<DiagGroup G> { DiagGroup Group = G; }
//class IsGroup<string Name> { DiagGroup Group = DiagGroup<Name>; }

// This defines documentation for diagnostic groups.
include "DiagnosticDocs.td"

// This defines all of the named diagnostic categories.
include "DiagnosticCategories.td"

// This defines all of the named diagnostic groups.
include "DiagnosticGroups.td"


// All diagnostics emitted by the compiler are an indirect subclass of this.
class Diagnostic<string summary, DiagClass DC, Severity defaultmapping> {
  /// Component is specified by the file with a big let directive.
  string         Component = ?;
  string         Summary = summary;
  DiagClass      Class = DC;
  SFINAEResponse SFINAE = SFINAE_Suppress;
  bit            AccessControl = 0;
  bit            WarningNoWerror = 0;
  bit            ShowInSystemHeader = 0;
  bit            ShowInSystemMacro = 1;
  bit            Deferrable = 0;
  Severity       DefaultSeverity = defaultmapping;
  DiagGroup      Group;
  string         CategoryName = "";
}

class SFINAEFailure {
  SFINAEResponse SFINAE = SFINAE_SubstitutionFailure;
}
class NoSFINAE {
  SFINAEResponse SFINAE = SFINAE_Report;
}
class AccessControl {
  SFINAEResponse SFINAE = SFINAE_AccessControl;
}

class ShowInSystemHeader {
  bit ShowInSystemHeader = 1;
}

class SuppressInSystemHeader {
  bit ShowInSystemHeader = 0;
}

class ShowInSystemMacro {
  bit ShowInSystemMacro = 1;
}

class SuppressInSystemMacro {
  bit ShowInSystemMacro = 0;
}

class Deferrable {
  bit Deferrable = 1;
}

class NonDeferrable {
  bit Deferrable = 0;
}

// FIXME: ExtWarn and Extension should also be SFINAEFailure by default.
class Error<string str>     : Diagnostic<str, CLASS_ERROR, SEV_Error>, SFINAEFailure {
  bit ShowInSystemHeader = 1;
}
// Warnings default to on (but can be default-off'd with DefaultIgnore).
// This is used for warnings about questionable code; warnings about
// accepted language extensions should use Extension or ExtWarn below instead.
class Warning<string str>   : Diagnostic<str, CLASS_WARNING, SEV_Warning>;
// Remarks can be turned on with -R flags and provide commentary, e.g. on
// optimizer decisions.
class Remark<string str>    : Diagnostic<str, CLASS_REMARK, SEV_Ignored>;
// Extensions are warnings about accepted language extensions.
// Extension warnings are default-off but enabled by -pedantic.
class Extension<string str> : Diagnostic<str, CLASS_EXTENSION, SEV_Ignored>;
// ExtWarns are warnings about accepted language extensions.
// ExtWarn warnings are default-on.
class ExtWarn<string str>   : Diagnostic<str, CLASS_EXTENSION, SEV_Warning>;
// Notes can provide supplementary information on errors, warnings, and remarks.
class Note<string str>      : Diagnostic<str, CLASS_NOTE, SEV_Fatal/*ignored*/>;


class DefaultIgnore { Severity DefaultSeverity = SEV_Ignored; }
class DefaultWarn   { Severity DefaultSeverity = SEV_Warning; }
class DefaultError  { Severity DefaultSeverity = SEV_Error; }
class DefaultFatal  { Severity DefaultSeverity = SEV_Fatal; }
class DefaultWarnNoWerror {
  bit WarningNoWerror = 1;
}
class DefaultRemark { Severity DefaultSeverity = SEV_Remark; }

class CompatWarningId<string name, int std, string diag, string diag_pre> {
  string Component = ?;
  string Name = name;
  string Diag = diag;
  string DiagPre = diag_pre;
  int Std = std;

  // This is unused, but Tablegen will complain if it's missing because we define
  // the compatibility ids in the same place as the other diagnostics (which means
  // that we'll be inside a 'let CategoryName = "" in { ... }' block).
  string CategoryName = ?;
}

// C++ compatibility warnings.
multiclass CXXCompat<
    string message,
    int std_ver,
    bit ext_warn = true,
    string std_ver_override = ""#std_ver> {
    // 'X is a C++YZ extension'.
    def compat_pre_cxx#std_ver#_#NAME :
        Diagnostic<!strconcat(message, " a C++", std_ver_override,  " extension"),
                   CLASS_EXTENSION,
                   !if(ext_warn, SEV_Warning, SEV_Ignored)>,
        InGroup<!cast<DiagGroup>("CXX"#std_ver)>;

    // 'X is incompatible with C++98' (if std_ver == 11).
    // 'X is incompatible with C++ standards before C++YZ' (otherwise).
    def compat_cxx#std_ver#_#NAME :
        Warning<!if(!eq(std_ver, 11),
                    !strconcat(message, " incompatible with C++98"),
                    !strconcat(message, " incompatible with C++ standards before C++", std_ver_override))>,
        InGroup<!cast<DiagGroup>(!if(!eq(std_ver, 11),
                                     "CXX98Compat",
                                     "CXXPre"#std_ver#"Compat"))>,
        DefaultIgnore;

    def : CompatWarningId<
        NAME, std_ver,
        "compat_cxx"#std_ver#"_"#NAME,
        "compat_pre_cxx"#std_ver#"_"#NAME>;
}

// These generate pairs of C++ compatibility warnings of the form:
//
//    - compat_cxx<std>_<name>
//    - compat_pre_cxx<std>_<name>
//
// The 'compat_cxx...' warning is intended to be issued in C++<std> mode,
// and the 'compat_pre_cxx...' warning in C++ modes before C++<std>.
//
// Example:
//
//   defm inline_variable : CXX17Compat<"inline variables are">;
//
// This generates two warnings:
//
//   - compat_cxx17_inline_variable:     'inline variables are incompatible with C++ standards before C++17'
//   - compat_pre_cxx17_inline_variable: 'inline variables are a C++17 extension'
//
multiclass CXX11Compat<string message, bit ext_warn = true> : CXXCompat<message, 11, ext_warn>;
multiclass CXX14Compat<string message, bit ext_warn = true> : CXXCompat<message, 14, ext_warn>;
multiclass CXX17Compat<string message, bit ext_warn = true> : CXXCompat<message, 17, ext_warn>;
multiclass CXX20Compat<string message, bit ext_warn = true> : CXXCompat<message, 20, ext_warn>;
multiclass CXX23Compat<string message, bit ext_warn = true> : CXXCompat<message, 23, ext_warn>;
multiclass CXX26Compat<string message, bit ext_warn = true> : CXXCompat<message, 26, ext_warn, "2c">;

// Definitions for Diagnostics.
include "DiagnosticASTKinds.td"
include "DiagnosticCommentKinds.td"
include "DiagnosticCommonKinds.td"
include "DiagnosticCrossTUKinds.td"
include "DiagnosticDriverKinds.td"
include "DiagnosticFrontendKinds.td"
include "DiagnosticInstallAPIKinds.td"
include "DiagnosticLexKinds.td"
include "DiagnosticParseKinds.td"
include "DiagnosticRefactoringKinds.td"
include "DiagnosticSemaKinds.td"
include "DiagnosticSerializationKinds.td"

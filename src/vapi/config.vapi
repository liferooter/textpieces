// SPDX-FileCopyrightText: 2021 Gleb Smirnov <glebsmirnov0708@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

[CCode (cprefix = "", lower_case_cprefix = "")]
namespace Config {
	public const string VERSION;
	public const string PKGDATADIR;
	public const string SCRIPTDIR;
	public const string GETTEXT_PACKAGE;
	public const string GNOMELOCALEDIR;
}

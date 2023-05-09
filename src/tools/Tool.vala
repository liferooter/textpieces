// Copyright 2021 Gleb Smirnov <glebsmirnov0708@gmail.com>
// SPDX-FileCopyrightText: 2021 Gleb Smirnov <glebsmirnov0708@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

using Gee;

namespace TextPieces {
    /**
     * Script result
     */
    public struct ScriptResult {
        string? output;
        string? error;
    }

    /**
     * Tool object class
     */
    public class Tool : Object {
        /**
         * Whether the application
         * is running in Flatpak
         */
        public static Lazy<bool> IN_FLATPAK = new Lazy<bool> (
            () => File.new_for_path ("/.flatpak-info").query_exists (null)
        );

        /**
         * Path to the directory containing
         * custom tool scripts
         */
        public static Lazy<string> CUSTOM_TOOLS_DIR = new Lazy<string> (
            /* Custom tools are stored in ~/.local/share/textpieces/scripts.
               They are there even in Flatpak because Flatpak-ed apps can't
               write to files from other apps' directories even through portals */
            () => Path.build_filename (
                Environment.get_home_dir (), ".local", "share", "textpieces", "scripts"
            )
        );

        /**
         * Name of the tool
         */
        public string name { get; set; }
        public string translated_name {
            get {
                return dpgettext2(null, "tools", name);
            }
        }

        /**
         * Description of the tool
         */
        public string description { get; set; }
        public string translated_description {
            get {
                return dpgettext2(null, "tools", description);
            }
        }

        /**
         * Tool script's command
         * line aguments
         */
        public string[] arguments;
        public string[] translated_arguments {
            owned get {
                string[] res = {};
                foreach (var arg in arguments) {
                    res += dpgettext2(null, "tools", arg);
                }

                return res;
            }
        }

        /**
         * The icon of the tool
         */
        public string icon = "applications-utilities-symbolic";

        /**
         * Tool script filename
         */
        public string script;

        /**
         * Whether the tool is pre-installed
         */
        public bool is_system;

        static construct {
            var tools_dir = File.new_for_path (CUSTOM_TOOLS_DIR.get ());

            /* Create tools directory */
            Utils.ensure_directory_exists.begin (tools_dir);
        }

        /**
         * Apply tool on text
         *
         * @param input input text
         * @param args  command line args tool script
         *
         * @return result of script executing
         */
        public ScriptResult apply (string input, string[] args) {
            /* Get directory containing script */
            var scriptdir = is_system
                ? Config.SCRIPTDIR
                : CUSTOM_TOOLS_DIR.get ();

            /* Build script command line */

            string[] cmdline = {};
            /* Run script on host via
               `flatpak-spawn --host`
               if running in Flatpak */
            if (!is_system && IN_FLATPAK.get ()) {
                cmdline += "flatpak-spawn";
                cmdline += "--host";
            }
            cmdline += Path.build_filename (scriptdir, script);

            /* Append args to command line */
            foreach (var arg in args)
                cmdline += arg;

            try {
                /* Run script */
                var process = new Subprocess.newv (
                    cmdline,
                    STDIN_PIPE  |
                    STDOUT_PIPE |
                    STDERR_PIPE
                );

                string stdout;
                string stderr;
                /* Send input to script, catch stdout and stderr */
                process.communicate_utf8 (input, null, out stdout, out stderr);

                bool success = process.get_successful ();

                return {
                    /* Return output if
                       script successed */
                    success
                        ? stdout
                        : null,
                    /* Return error if stderr
                       is not empty */
                    (stderr ?? "") != ""
                        ? Markup.escape_text (stderr, -1)
                        : null
                };
            } catch (Error e) {
                critical ("Internal error: %s", e.message);
                return {
                    e.message,
                    null
                };
            }
        }

        /**
         * Edit tool script with external editor
         */
        public void open (Gtk.Window? window)
                requires (!this.is_system) {
            new Xdp.Portal ().open_uri.begin (
                Xdp.parent_new_gtk(window),
                File.new_build_filename (
                    Tool.CUSTOM_TOOLS_DIR.get (), this.script
                ).get_uri (),
                ASK | WRITABLE,
                null
            );
        }

        /**
         * Generate filename for tool script
         */
        public static string generate_filename (string name) {
            /* Generate salt */
            var salt = Checksum.compute_for_string (
                SHA256,
                Random.next_int  ()
                      .to_string ()
            ).slice (0, 8);

            /* Generate filename in form:
               "filename-salt", where salt
               is eight random characters */
            return "%s-%s".printf (
                name.down ()
                    .replace (" ", "_")
                    .replace ("?", "x"),
                salt
            );
        }
    }

    /**
     * Build tool row
     */
    Gtk.Widget build_list_row (Object item) {
        var tool = (Tool) item;

        return new Adw.ActionRow () {
            title = tool.translated_name,
            subtitle = tool.translated_description,
            icon_name = tool.icon,
            activatable = true
        };
    }
}

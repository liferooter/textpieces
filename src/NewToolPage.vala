// Copyright 2021 Gleb Smirnov <glebsmirnov0708@gmail.com>
// SPDX-FileCopyrightText: 2021 Gleb Smirnov <glebsmirnov0708@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

namespace TextPieces {
    /**
     * Custom tool create page
     */
    [GtkTemplate (ui = "/com/github/liferooter/textpieces/ui/NewToolPage.ui")]
    class NewToolPage : Gtk.Box {
        [GtkChild] unowned ToolSettings tool_settings;

        /**
         * Parent preferences window
         */
        public Preferences prefs { get; construct; }

        /**
         * Pre-created tool
         *
         * This tool isn't presented
         * in tools model and added to
         * the model on create
         */
        private Tool new_tool;

        public NewToolPage (Preferences prefs) {
            Object (
                prefs: prefs
            );
        }

        construct {
            /* Initialize tool */
            new_tool = new Tool () {
                name = "",
                description = "",
                arguments = {},
                script = "",
                is_system = false
            };

            /* Setup tool settings widget */
            tool_settings.set_tool (new_tool);
            tool_settings.window = prefs;
        }

        [GtkCallback]
        void go_back () {
            prefs.close_subpage ();
        }

        /**
         * Create tool
         *
         * This method is called when
         * create button is clicked.
         * It saves tool and exits.
         */
        [GtkCallback]
        async void create () {
            /* Create tool directory if not exists */
            var dir = File.new_for_path (Tool.CUSTOM_TOOLS_DIR);
            if (!dir.query_exists ()) {
                try {
                    yield Utils.ensure_directory_exists (dir);
                } catch (Error e) {
                    error ("Can't create directory for tool scripts: %s", e.message);
                }
            }

            /* Generate script filename with salt */
            var filename = Tool.generate_filename (name);

            /* Get script file */
            var script_file = File.new_build_filename (
                Tool.CUSTOM_TOOLS_DIR,
                filename
            );

            /* Get template file */
            var template_file = File.new_build_filename (
                Config.SCRIPTDIR,
                "template"
            );

            /* Copy template to file */
            try {
                yield template_file.copy_async (
                    script_file,
                    OVERWRITE
                );
            } catch (Error err) {
                error ("Can't copy script template to file: %s".printf (err.message));
            }

            /* Change file permissions */
            FileUtils.chmod (script_file.get_path (), 0750); // rwxr-x---

            /* Set script filename to the tool */
            new_tool.script = filename;

            /* Add new tool to tools */
            Application.tools.add_tool (
                new_tool
            );
            try {
                yield Application.tools.commit ();
            } catch (Error e) {
                critical ("Can't commit tools: %s", e.message);
                prefs.add_toast (new Adw.Toast (
                    _("Error occured: %s").printf (e.message)
                ));
            }

            /* Open tool script in
               your favorite editor */
            new_tool.open (prefs);
        }
    }
}

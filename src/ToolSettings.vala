namespace TextPieces {
    [GtkTemplate (ui = "/com/github/liferooter/textpieces/ui/ToolSettings.ui")]
    class ToolSettings : Adw.Bin {
        [GtkChild] unowned Gtk.Entry name_entry;
        [GtkChild] unowned Gtk.Entry description_entry;
        [GtkChild] unowned Gtk.SpinButton arguments_number;
        [GtkChild] unowned Gtk.ListBox argument_list;
        [GtkChild] unowned Gtk.ListBox edit_script_list;

        public Gtk.Window? window = null;

        /**
         * Whether all entered data is valid
         */
        public bool is_valid { get; set; }

        /**
         * Whether to allow edit script
         */
        public bool can_edit_script { get; construct; default = false; }

        /**
         * Tool which this settings is of
         */
        private Tool? tool = null;

        /**
         * Model of tool arguments
         */
        private ListStore arguments =
            new ListStore (typeof (Argument));

        /**
         * Tool argument class
         */
        private class Argument : Object {
            /**
             * Index of the argument
             */
            public int index { get; construct set; }

            /**
             * Tool which the argument belongs to
             */
            public Tool tool { get; construct; }

            /**
             * Name of the argument
             */
            public string name { get; construct set; }

            /**
             * Create argument object
             *
             * @param index index of the argument
             * @param tool tool which the argument belongs to
             */
            public Argument (int index, Tool tool) {
                Object (
                    index: index,
                    tool: tool
                );
            }

            construct {
                /* Get argument name from tool */
                name = tool.arguments[index] ?? "";

                /* Update tool argument name
                   on argument's name changes */
                notify["name"].connect_after (() => {
                    tool.arguments[index] = name;
                });
            }
        }

        construct {
            edit_script_list.visible = can_edit_script;

            name_entry.bind_property (
                "text",
                this,
                "is-valid",
                SYNC_CREATE,
                (_, from, ref to) => {
                    to.set_boolean (from.get_string () != "");

                    return true;
                }
            );

            arguments_number.value_changed.connect (() => {
                /* Add arguments */
                while (arguments_number.value > arguments.get_n_items ()) {
                    var arg = new Argument (
                        (int) arguments.get_n_items (),
                        tool
                    );
                    arguments.append (arg);
                }

                /* Remove arguments */
                while (arguments_number.value < arguments.get_n_items ()) {
                    arguments.remove (arguments.get_n_items () - 1);
                }
            });
        }

        /**
         * Set tool for tool settings.
         *
         * Can be called only when
         * tool is not set.
         *
         * @param tool tool to set
         */
        public void set_tool (Tool tool)
                requires (this.tool == null) {
            /* Save tool in private field */
            this.tool = tool;

            /* Bind tool name */
            tool.bind_property (
                "name",
                name_entry,
                "text",
                BIDIRECTIONAL | SYNC_CREATE,
                null,
                (_, from, ref to) => {
                    var name = from.get_string ();

                    if (name != "") {
                        to.set_string (name);
                        name_entry.remove_css_class ("error");
                        return true;
                    } else {
                        name_entry.add_css_class ("error");
                        return false;
                    }
                }
            );

            /* Bind tool description */
            tool.bind_property (
                "description",
                description_entry,
                "text",
                BIDIRECTIONAL | SYNC_CREATE
            );

            /* Load tool arguments to model */
            arguments_number.value = tool.arguments.length;
            arguments_number.value_changed ();

            /* Show arguments list
               if there are any arguments */
            argument_list.visible = arguments.get_n_items () != 0;

            /* Setup model rendering */
            argument_list.bind_model (
                arguments,
                (obj) => {
                    var arg = obj as Argument;

                    /* Create entry for argument name,
                       align it to the center to don't
                       stretch to the full height of row */
                    var entry = new Gtk.Entry () {
                        valign = CENTER
                    };

                    /* Create row itself
                       set title "Argument N",
                       make entry focusable
                       by click on row */
                    var row = new Adw.ActionRow () {
                        title = @"Argument $(arg.index + 1)",
                        activatable_widget = entry
                    };

                    /* Add entry to the row */
                    row.add_suffix (entry);

                    /* Bind entry text to
                       argument name */
                    arg.bind_property (
                        "name",
                        entry,
                        "text",
                        BIDIRECTIONAL | SYNC_CREATE
                    );

                    return row;
                }
            );

            /* Update tool arguments on model chages */
            arguments.items_changed.connect ((pos, removed, added) => {
                /* Get new arguments */
                var new_args = new string[added];
                for (var i = 0; i < added; i++) {
                    var arg = arguments.get_item (pos + i) as Argument;
                    new_args[i] = arg.name;
                }

                /* Update tool arguments */
                var args = tool.arguments[:pos];
                foreach (var new_arg in new_args)
                    args += new_arg;
                foreach (var old_arg in tool.arguments[pos + removed:])
                    args += old_arg;
                tool.arguments = args;

                /* Update arguments' indexes */
                for (var i = pos + added; i < arguments.get_n_items (); i++) {
                    var arg = arguments.get_item (i) as Argument;
                    arg.index = (int) i;
                }

                /* Show list if there are any tools */
                argument_list.visible = arguments.get_n_items () != 0;
            });
        }

        [GtkCallback]
        void edit_script () {
            tool.open (window);
        }
    }
}
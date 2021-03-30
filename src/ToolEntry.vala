namespace Textpieces {
    [GtkTemplate (ui = "/com/github/liferooter/textpieces/ui/tool-entry.ui")]
    class ToolEntry : Gtk.Entry {
        private ToolsPopover? popover = null;

        [Signal (action = true)]
        public virtual signal void show_tools_popover () {
            if (popover == null) {
                popover = new ToolsPopover (this);

                popover.hide.connect (() => {
                    popover = null;
                });
                popover.select_tool.connect ((tool) => select_tool (tool));
                
                popover.popup ();
            } else {
                popover.popdown ();
            }
        }

        [Signal (action = true)]
        public virtual signal void select_tool (Tool tool) {
            primary_icon_name = tool.icon;
            text = tool.name;
        }

        construct {
            this.button_press_event.connect (() => {
                show_tools_popover ();
            });
        }
    }
}
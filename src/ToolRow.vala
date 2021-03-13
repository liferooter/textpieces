namespace Textpieces {

    [GtkTemplate (ui = "/com/github/liferooter/textpieces/ui/tool-row.ui")]
    class ToolRow : Gtk.ListBoxRow {

        [GtkChild]
        Gtk.Image tool_image;
        [GtkChild]
        Gtk.Label tool_label;

        public Tool tool {get; construct; }

        public ToolRow (Tool _tool) {
            Object (
                tool: _tool
            );

            tool_label.set_text (tool.name);
            tool_image.icon_name = tool.icon;
        }
    }
}

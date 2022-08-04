// SPDX-FileCopyrightText: 2022 Gleb Smirnov <glebsmirnov0708@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later


[GtkTemplate(ui = "/com/github/liferooter/textpieces/ui/SearchEntry.ui")]
class TextPieces.SearchEntry : Gtk.Widget {
    [GtkChild] unowned Gtk.Text text;

    /**
     * Current search query
     */
    public string query { get; set; }

    /**
     * Current information string about occurrences count and position
     */
    public string occurrences_info { get; set; }

    /**
     * occurrences count
     */
    public int occurrences_count { get; set; }

    /**
     * Position of current occurrence
     */
    public uint occurrence_position { get; set; }

    class construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
        set_css_name ("entry");
        set_accessible_role (TEXT_BOX);
    }

    construct {
        text.bind_property (
            "text",
            this,
            "query"
        );

        notify["occurrences-count"].connect (update_info);
        notify["occurrence-position"].connect (update_info);
        update_info ();
    }

    public void set_context (GtkSource.SearchContext context) {
        /* Bind occurrences count */
        context.bind_property (
            "occurrences-count",
            this,
            "occurrences-count"
        );

        /* Bind occurrence position */
        var buffer = context.buffer;
        buffer.changed.connect (() => {
            update_occurrence_position (context);
        });

        buffer.notify["cursor-position"].connect (() => {
            update_occurrence_position (context);
        });

        text.changed.connect (() => {
            update_occurrence_position (context);
        });

        context.notify.connect(() => {
            update_occurrence_position (context);
        });
    }

    private void update_occurrence_position (GtkSource.SearchContext context) {
        Gtk.TextIter? start, end;
        context.buffer.get_selection_bounds (out start, out end);
        if (start != null && end != null) {
            var position = context.get_occurrence_position (start, end);
            occurrence_position = position >= 0
                ? position
                : 0;
        }
    }

    public override bool grab_focus () {
        return text.grab_focus ();
    }

    public void update_info () {
        var info = "";
        if (occurrences_count != 0) {
            info = _("%u of %d").printf (
                occurrence_position,
                occurrences_count
            );
        }

        this.occurrences_info = info;
    }
}

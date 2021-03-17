namespace Textpieces {
    class JSTool : Object{
        public string code { get; construct; }

        public JSTool (string code) {
            Object (
                code: code
            );
        }

        public string? run (string input, string[] args, out string? err) {
            var ctx = new JSC.Context ();
            ctx.set_value ("input", new JSC.Value.string (ctx, input));
            ctx.set_value ("args", new JSC.Value.array_from_strv (ctx, args));
            
            ctx.evaluate (code, -1);
			var res = ctx.get_value ("result");
            var err_val = res.object_get_property ("err");
            if (err_val.is_string ()) 
                err = err_val.to_string ();
            else
                err = null;
            var output_val = res.object_get_property ("output");
            if (output_val.is_string ())
                return output_val.to_string ();
            else
                return null;
        }
    }
}
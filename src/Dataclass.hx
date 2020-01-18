import haxe.macro.Expr;
import haxe.macro.Context;

class Dataclass {
    static public macro function constructor(): Array<Field> {
        var fields = Context.getBuildFields();
        var args: Array<FunctionArg> = [];
        var exprs: Array<Expr> = [];

        for (field in fields) {
            switch (field.kind) {
                case FVar(t, e):
                    final name = field.name;
                    final arg = {name: name, type: t};
                    args.push(arg);
                    final expr = macro this.$name = $i{name};
                    exprs.push(expr);
                default:
            }
        }

        final func: Function = {
            args: args,
            ret: (macro:Void),
            expr: macro $b{exprs},
        };

        final field: Field = {
            name: "new",
            kind: FFun(func),
            access: [Access.APublic],
            pos: Context.currentPos(),
        };

        fields.push(field);
        return fields;
    }
}
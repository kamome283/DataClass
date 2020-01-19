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

    static public macro function makePublic(): Array<Field> {
        var fields = Context.getBuildFields();      
        for (field in fields) {
            switch (field.kind) {
                case FVar(_):
                    field.access.remove(Access.APrivate);
                    field.access.push(Access.APublic);
                default:
            }
        }
        return fields;
    }

    static public macro function copy(): Array<Field> {
        final classType = Context.getClassPath();
        var fields = Context.getBuildFields();
        var args: Array<FunctionArg> = [];
        var types: Array<ComplexType> = [];
        var exprs: Array<Expr> = [];
        for (field in fields) {
            switch (field.kind) {
                case FVar(t, e):
                    final name = field.name;
                    final type: ComplexType = TNamed(name, t);
                    types.push(type);
                    final expr = macro fields.$name == null ? this.$name : fields.$name;
                    exprs.push(expr);
                default:
            }
        }
        final type = TOptional(TIntersection(types));
        final arg: FunctionArg = {name: "fields", type: type};
        final func: Function = {
            args: [arg],
            ret: null, // return Self
            expr: macro return new $classType(${exprs[0]}, ${exprs[1]})
        };
        return fields;
    }
}
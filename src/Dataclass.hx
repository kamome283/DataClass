import haxe.macro.Expr;
import haxe.macro.Context;

class Dataclass {
	public static macro function constructor():Array<Field> {
		var fields = Context.getBuildFields();
		var args:Array<FunctionArg> = [];
		var exprs:Array<Expr> = [];

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

		final func:Function = {
			args: args,
			ret: (macro:Void),
			expr: macro $b{exprs},
		};

		final field:Field = {
			name: "new",
			kind: FFun(func),
			access: [Access.APublic],
			pos: Context.currentPos(),
		};

		fields.push(field);
		return fields;
	}

	public static macro function makePublic():Array<Field> {
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

	public static macro function copy():Array<Field> {
		var classFields = Context.getBuildFields();

		var types:Array<ComplexType> = [];
		var params:Array<Expr> = [];
		for (f in classFields) {
			switch (f.kind) {
				case FVar(t, e):
					final name = f.name;
					var t = ComplexType.TAnonymous([
						{
							name: name,
							pos: Context.currentPos(),
							kind: FVar(t),
							meta: [
								{
									name: ':optional',
									params: [],
									pos: f.pos
								}
							]
						}
					]);
					types.push(t);
					params.push(macro fields.$name == null ? this.$name : fields.$name);
				default:
			}
		}

		final typepath:TypePath = {
			var pack = [];
			final name = Context.getLocalClass().get().name;
			{name: name, pack: pack}
		};

		final funcExpr:Expr = {
			final constructExpr:Expr = {expr: ENew(typepath, params), pos: Context.currentPos()};

			macro {
				return $constructExpr;
			}
		}

		final func:Function = {
			args: [{name: "fields", type: TIntersection(types)}],
			ret: TPath(typepath),
			expr: funcExpr,
		}

		final field:Field = {
			name: "copy",
			kind: FFun(func),
			access: [Access.APublic],
			pos: Context.currentPos(),
		};

		classFields.push(field);
		return classFields;
	}
}

import haxe.macro.Expr;
import haxe.macro.Context;

using Lambda;

@:remove
@:autoBuild(DataClassImpl.constructor())
@:autoBuild(DataClassImpl.makePublic())
@:autoBuild(DataClassImpl.copy())
@:autoBuild(DataClassImpl.equals())
@:autoBuild(DataClassImpl.init())
interface DataClass {}

@:remove
class DataClassImpl {
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
			access: [APrivate],
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

	public static macro function equals():Array<Field> {
		var classFields = Context.getBuildFields();

		final comparison:Expr = {
			var comparisons:Array<Expr> = [];
			for (f in classFields) {
				switch (f.kind) {
					case FVar(t, e):
						final name = f.name;
						comparisons.push(macro this.$name == rhs.$name);
					default:
				}
			}
			final lastComp = comparisons.pop();

			comparisons.fold((comp, acc) -> macro $acc && $comp, lastComp);
		}

		final classType:ComplexType = TPath({
			name: Context.getLocalClass().get().name,
			pack: [],
		});

		final c = macro class {
			public function equals(rhs:$classType):Bool {
				return $comparison;
			}
		}

		return classFields.concat(c.fields);
	}

	public static macro function init():Array<Field> {
		var classFields = Context.getBuildFields();
		final classTypePath:TypePath = {name: Context.getLocalClass().get().name, pack: []};
		final classType:ComplexType = TPath(classTypePath);

		final hasInitFunc = classFields.exists(f -> {
			return switch (f.kind) {
				case FFun(_) if (f.name == "init"):
					true;
				case _ if (f.name == "init"):
					Context.error('"init" field must be function', Context.currentPos());
				default:
					false;
			}
		});
		if (hasInitFunc)
			return classFields;

		var args:Array<FunctionArg> = [];
		var params:Array<Expr> = [];
		for (f in classFields) {
			switch (f.kind) {
				case FVar(t, e):
					args.push({name: f.name, type: t});
					params.push(macro $i{f.name});
				default:
			}
		}

		final func:Function = {
			args: args,
			ret: classType,
			expr: {
				expr: EReturn({
					expr: ENew(classTypePath, params),
					pos: Context.currentPos()
				}),
				pos: Context.currentPos()
			}
		};

		final field:Field = {
			name: "init",
			kind: FFun(func),
			access: [APublic, AStatic, AInline],
			pos: Context.currentPos(),
		};

		classFields.push(field);
		return classFields;
	}
}

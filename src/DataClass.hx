import haxe.macro.Expr;
import haxe.macro.Context;

using Lambda;

@:remove
@:autoBuild(DataClassImpl.genConstructor())
@:autoBuild(DataClassImpl.makeVarsPublic())
@:autoBuild(DataClassImpl.genCopy())
@:autoBuild(DataClassImpl.genEquals())
@:autoBuild(DataClassImpl.genInit())
interface DataClass {}

@:remove
final class DataClassImpl {
	#if macro
	public static macro function genConstructor():Array<Field> {
		var classFields = Context.getBuildFields();

		var args:Array<FunctionArg> = [];
		var exprs:Array<Expr> = [];
		for (f in classFields) {
			switch (f.kind) {
				case FVar(t, e):
					final name = f.name;
					args.push({name: name, type: t});
					exprs.push(macro this.$name = $i{name});
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

		classFields.push(field);
		return classFields;
	}

	public static macro function makeVarsPublic():Array<Field> {
		var classFields = Context.getBuildFields();

		for (f in classFields) {
			switch (f.kind) {
				case FVar(_):
					if (f.access.has(APrivate)) {
						Context.error('DataClass variables cannot make private.', Context.currentPos());
					}
					f.access.push(Access.APublic);
				default:
			}
		}

		return classFields;
	}

	public static macro function genCopy():Array<Field> {
		var classFields = Context.getBuildFields();
		final classTypePath:TypePath = {name: Context.getLocalClass().get().name, pack: []};
		final classType:ComplexType = TPath(classTypePath);

		var types:Array<ComplexType> = [];
		var params:Array<Expr> = [];
		for (f in classFields) {
			switch (f.kind) {
				case FVar(t, e):
					final name = f.name;
					final type = ComplexType.TAnonymous([
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
					types.push(type);
					params.push(macro fields.$name == null ? this.$name : fields.$name);
				default:
			}
		}

		final func:Function = {
			args: [{name: "fields", type: TIntersection(types)}],
			ret: classType,
			expr: {
				final constructExpr:Expr = {expr: ENew(classTypePath, params), pos: Context.currentPos()};
				macro {
					return $constructExpr;
				}
			}
		};

		final field:Field = {
			name: "copy",
			kind: FFun(func),
			access: [Access.APublic],
			pos: Context.currentPos(),
		};

		classFields.push(field);
		return classFields;
	}

	public static macro function genEquals():Array<Field> {
		var classFields = Context.getBuildFields();
		final classTypePath:TypePath = {name: Context.getLocalClass().get().name, pack: []};
		final classType:ComplexType = TPath(classTypePath);

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
			final firstComp = comparisons.shift();
			comparisons.fold((comp, acc) -> macro $acc && $comp, firstComp);
		}

		final c = macro class {
			public function equals(rhs:$classType):Bool {
				return $comparison;
			}
		}
		return classFields.concat(c.fields);
	}

	public static macro function genInit():Array<Field> {
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
	#end
}

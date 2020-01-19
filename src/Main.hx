import Dataclass;

class Main {
    static public function main() {
        final p1 = new Person("Tsubasa", 24);
        trace(p1.title);
        trace(p1.name);
        trace("Hello, World!");
    }
}

@:build(Dataclass.constructor())
@:build(Dataclass.makePublic())
class Person {
    final name: String;
    final age: Int;
    public var title(get, never): String;
    inline private function get_title()
        return '${name}(${age})';

    public function copy(?fields: {?name: String, ?age: Int}): Person {
        if (fields == null) {
            return copy({});
        }

        return new Person(
            fields.name == null ? name : fields.name,
            fields.age == null ? age : fields.age
        );
    }
}
part of rpg;

class WorldMap {
  String _name;
  List<List<Element>> _elements;

  WorldMap(String this._name) {}

  Future<WorldConfiguration> load() async {
    return _processString(
        await html.HttpRequest.getString('world/' + _name + ".json"));
  }

  draw(LevelUp.GameStage stage) {
    if (_elements == null) {
      throw new Exception("_elements==null");
    }

    int lineNumber = 0;
    for (List<Element> line in _elements) {
      int elementNumber = 0;
      for (Element element in line) {
        LevelUp.PixiPhysicsItem physicElement =
            new LevelUp.PixiPhysicsItem(element)
              ..position = new PIXI.Point.fromValues(
                  Element.SIZE * elementNumber, Element.SIZE * lineNumber);

        stage.addChild(physicElement);
        elementNumber++;
      }

      lineNumber++;
    }
  }

  WorldConfiguration _processString(String jsonString) {
    List<List<Map>> lines = JSON.decode(jsonString);

    _elements = new List();
    int largestLine = 0;

    for (List<Map> line in lines) {
      List<Element> lineElements = new List();

      for (Map<String, dynamic> element in line) {
        String type = element["type"] as String;

        Element elem;
        switch (type) {
          case "GROUND":
            elem = new Ground();
            break;
          case 'WALL':
            elem = new Wall();
            break;
          case 'VOID':
            elem = new Void();
            break;
          default:
            throw new Exception("Unknown type: $type");
        }

        lineElements.add(elem);
      }

      if (lineElements.length > largestLine) {
        largestLine = lineElements.length;
      }

      _elements.add(lineElements);
    }

    return new WorldConfiguration(largestLine, _elements.length);
  }
}

class WorldConfiguration {
  int width;
  int height;

  WorldConfiguration(int this.width, this.height) {}
}

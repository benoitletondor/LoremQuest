part of rpg;

class WorldMap {
  String _name;
  List<List<Element>> _elements;
  Map<String, PIXI.Resource> _resources;

  List<Mob> _mobs;
  int playerX = 0;
  int playerY = 0;

  WorldMap(String this._name, Map<String, PIXI.Resource> this._resources) {}

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

    int x = 1;
    int y = 1;

    _elements = new List();
    _mobs = new List();

    for (List<Map> line in lines) {
      List<Element> lineElements = new List();

      for (Map<String, dynamic> element in line) {
        String type = element["type"];

        PIXI.Rectangle frame = null;
        if (element.containsKey("frame")) {
          Map<String, num> frameObject = element["frame"];
          frame = new PIXI.Rectangle.fromValues(frameObject["x"],
              frameObject["y"], frameObject["w"], frameObject["h"]);
        }

        Element elem;
        switch (type) {
          case "GROUND":
            elem = new GroundElement(_resources["forest"].texture, frame);
            break;
          case 'WALL':
            elem = new WallElement(_resources["forest"].texture, frame);
            break;
          case 'VOID':
            elem = new VoidElement();
            break;
          default:
            throw new Exception("Unknown type: $type");
        }

        if (element.containsKey("contains")) {
          _parseContained(element["contains"], x, y);
        }

        lineElements.add(elem);
        x++;
      }

      _elements.add(lineElements);
      y++;
      x = 1;
    }

    if (playerX == 0 && playerY == 0) {
      throw new Exception("Player not found");
    }

    return new WorldConfiguration(
        _elements[0].length, _elements.length, playerX, playerY, _mobs);
  }

  _parseContained(List<Map<String, dynamic>> containedList, int x, int y) {
    for (Map<String, dynamic> contained in containedList) {
      String containedType = contained["type"];

      switch (containedType) {
        case "Player":
          playerX = x;
          playerY = y;
          break;
        case "Mob":
          _parseMob(contained, x, y);
          break;
      }
    }
  }

  _parseMob(Map<String, dynamic> contained, int x, int y) {
    String mobKind = contained["kind"];

    switch (mobKind) {
      case "SPIDER":
        _mobs.add(new SpiderMob(
            _resources["spider"].texture..frame = SpiderMob.frames[0], x, y));
        break;
      default:
        throw new Exception("Unknown mob kind: $mobKind");
    }
  }
}

class WorldConfiguration {
  int width;
  int height;

  int playerX;
  int playerY;

  List<Mob> mobs;

  WorldConfiguration(
      int this.width, this.height, this.playerX, this.playerY, this.mobs) {}
}

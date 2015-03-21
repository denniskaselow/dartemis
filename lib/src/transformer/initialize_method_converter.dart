part of transformer;

class InitializeMethodConverter {
  final Map<String, ClassHierarchyNode> _nodes;

  InitializeMethodConverter(this._nodes);

  bool convert(ClassDeclaration unit) {
    var fieldCollector = new FieldCollectingAstVisitor(_nodes);
    unit.visitChildren(fieldCollector);
    if (fieldCollector.managers.isEmpty && fieldCollector.systems.isEmpty && fieldCollector.mappers.isEmpty) {
      return false;
    }
    bool callSuperInitialize = false;
    var initializeMethod = unit.getMethod('initialize');
    if (null == initializeMethod) {
      initializeMethod = _createInitializeMethodDeclaration();
      unit.members.add(initializeMethod);
      callSuperInitialize = true;
    }
    var initializeStatements = (initializeMethod.body as BlockFunctionBody).block.statements;

    var initField = (FieldDeclaration node, ExpressionStatement createAssignment(String name, String type)) {
      var managerName = node.fields.variables[0].name.name;
      var managerType = node.fields.type.name.name;
      initializeStatements.insert(0, createAssignment(managerName, managerType));
    };
    fieldCollector.managers.forEach((manager) => initField(manager, (String name, String type) => _createManagerAssignment(name, type)));
    fieldCollector.systems.forEach((system) => initField(system, (String name, String type) => _createSystemAssignment(name, type)));
    fieldCollector.mappers.forEach((FieldDeclaration mapper) {
      var mapperName = mapper.fields.variables[0].name.name;
      var mapperType = mapper.fields.type.typeArguments.arguments[0].name.name;
      initializeStatements.insert(0, _createMapperAssignment(mapperName, mapperType));
    });

    if (callSuperInitialize) {
      initializeStatements.insert(0, _createSuperInitialize());
    }
    return true;
  }

  MethodDeclaration _createInitializeMethodDeclaration() {
    var comment = null;
    var metadata = [AstFactory.annotation(AstFactory.identifier3('override'))];
    var externalKeyword = null;
    var modifierKeyword = null;
    var returnType = AstFactory.typeName4('void');
    var propertyKeyword = null;
    var operatorKeyword = null;
    var name = AstFactory.identifier3('initialize');
    var parameters = AstFactory.formalParameterList();
    var block = AstFactory.block();
    var body = AstFactory.blockFunctionBody(block);
    return new MethodDeclaration(comment, metadata, externalKeyword, modifierKeyword, returnType, propertyKeyword, operatorKeyword, name, parameters, body);
  }

  ExpressionStatement _createSuperInitialize() {
    var expression = AstFactory.methodInvocation(AstFactory.identifier3('super'), 'initialize');
    return AstFactory.expressionStatement(expression);
  }

  ExpressionStatement _createMapperAssignment(String mapperName, String mapperType) {
    var leftHandSide = AstFactory.identifier3(mapperName);
    var rightHandSide = AstFactory.instanceCreationExpression2(Keyword.NEW, AstFactory.typeName3(AstFactory.identifier3('Mapper'), [AstFactory.typeName4(mapperType)]), [AstFactory.identifier3(mapperType), AstFactory.identifier3('world')]);
    var assigmentStatement = AstFactory.assignmentExpression(leftHandSide, TokenType.EQ, rightHandSide);
    return AstFactory.expressionStatement(assigmentStatement);
  }

  ExpressionStatement _createManagerAssignment(String managerName, String managerType) =>
    _createAssignmentFromWorldMethod(managerName, managerType, 'getManager');

  ExpressionStatement _createSystemAssignment(String systemName, String systemType) =>
    _createAssignmentFromWorldMethod(systemName, systemType, 'getSystem');

  ExpressionStatement _createAssignmentFromWorldMethod(String fieldName, String fieldType, String worldMethod) {
    var leftHandSide = AstFactory.identifier3(fieldName);
    var rightHandSide = AstFactory.methodInvocation(AstFactory.identifier3('world'), worldMethod, [AstFactory.identifier3(fieldType)]);
    var assigmentStatement = AstFactory.assignmentExpression(leftHandSide, TokenType.EQ, rightHandSide);
    return AstFactory.expressionStatement(assigmentStatement);
  }
}

class FieldCollectingAstVisitor extends SimpleAstVisitor {
  List<FieldDeclaration> mappers = <FieldDeclaration>[];
  List<FieldDeclaration> managers = <FieldDeclaration>[];
  List<FieldDeclaration> systems = <FieldDeclaration>[];
  Map<String, ClassHierarchyNode> nodes;

  FieldCollectingAstVisitor(this.nodes);

  @override
  visitFieldDeclaration(FieldDeclaration node) {
    if (null != node.fields.type) {
      var typeName = node.fields.type.name.name;
      if (typeName == 'Mapper') {
        mappers.add(node);
      } else if (_isOfType(nodes, typeName, 'Manager')) {
        managers.add(node);
      } else if (_isOfType(nodes, typeName, 'EntitySystem')) {
        systems.add(node);
      }
    }
  }
}
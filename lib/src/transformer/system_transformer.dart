part of transformer;

class SystemTransformer extends Transformer implements DeclaringTransformer {

  SystemTransformer.asPlugin();

  @override
  String get allowedExtensions => ".dart";

  @override
  apply(Transform transform) {
    return transform.primaryInput.readAsString().then((content) {
      processContent(transform, content);
    });
  }

  void processContent(Transform transform, String content) {
    var unit = parseCompilationUnit(content);
    unit.visitChildren(new MapperInitializingAstVisitor());
    transform.addOutput(new Asset.fromString(transform.primaryInput.id, unit.toSource()));
  }

  @override
  declareOutputs(DeclaringTransform transform) {
    transform.declareOutput(transform.primaryId);
  }
}

class MapperInitializingAstVisitor extends SimpleAstVisitor<AstNode> {

  @override
  ClassDeclaration visitClassDeclaration(ClassDeclaration node) {
    var initializeMethodDeclaration = node.getMethod('initialize');
    if (null == node.getMethod('initialize')) {
      node.members.add(createInitializeMethodDeclaration());
    } else {
      (initializeMethodDeclaration.body as BlockFunctionBody).block.statements.insert(0, createMapperAssignment('pm', 'Position'));
    }
    return node;
  }
}

MethodDeclaration createInitializeMethodDeclaration() {
  var comment = null;
  var metadata = [new Annotation(new Token(TokenType.AT, 0), new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, 'override', 0)), null, null, null)];
  var externalKeyword = null;
  var modifierKeyword = null;
  var returnType = new TypeName(new SimpleIdentifier(new KeywordToken(Keyword.VOID, 0)), null);
  var propertyKeyword = null;
  var operatorKeyword = null;
  var name = new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, 'initialize', 0));
  var parameters = new FormalParameterList(new BeginToken(TokenType.OPEN_PAREN, 0), null, null, null, new Token(TokenType.CLOSE_PAREN, 0));
  var statements = [createMapperAssignment('pm', 'Position')];
  var block = new Block(new BeginToken(TokenType.OPEN_CURLY_BRACKET, 0), statements, new Token(TokenType.CLOSE_CURLY_BRACKET, 0));
  var body = new BlockFunctionBody(null, null, block);
  return new MethodDeclaration(comment, metadata, externalKeyword, modifierKeyword, returnType, propertyKeyword, operatorKeyword, name, parameters, body);
}

ExpressionStatement createMapperAssignment(String mapperName, String mapperType) {
  var rightHandSide = new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, mapperName, 0));
  var keyword = new KeywordToken(Keyword.NEW, 0);
  var arguments = [new TypeName(new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, mapperType, 0)), null)];
  var typeArguments = new TypeArgumentList(new Token(TokenType.LT, 0), arguments, new Token(TokenType.GT, 0));
  var period = null;
  var name = null;
  var constructorName = new ConstructorName(new TypeName(new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, 'Mapper', 0)), typeArguments), period, name);
  var argumentList = new ArgumentList(new BeginToken(TokenType.OPEN_PAREN, 0), [new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, mapperType, 0)), new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, 'world', 0))], new Token(TokenType.CLOSE_PAREN, 0));
  var leftHandSide = new InstanceCreationExpression(keyword, constructorName, argumentList);
  var assigmentStatement = new AssignmentExpression(rightHandSide, new Token(TokenType.EQ, 0), leftHandSide);
  return new ExpressionStatement(assigmentStatement, new Token(TokenType.SEMICOLON, 0));
}
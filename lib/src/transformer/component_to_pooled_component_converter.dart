part of transformer;


class ComponentToPooledComponentConverter {

  void convert(ClassDeclaration unit) {
    var className = unit.name.name;
    unit.extendsClause.superclass.name = new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, 'PooledComponent', 0));

    unit.members.add(_createStaticConstructorMethod(className));
    unit.members.add(_createHiddenConstructor(className));
    unit.members.add(_createFactoryConstructor(className));
    print(unit);
  }

  MethodDeclaration _createStaticConstructorMethod(String className) {
    Comment comment = null;
    List<Annotation> metadata = null;
    Token externalKeyword = null;
    Token modifierKeyword = new KeywordToken(Keyword.STATIC, 0);
    TypeName returnType = new TypeName(new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, className, 0)), null);
    Token propertyKeyword = null;
    Token operatorKeyword = null;
    SimpleIdentifier name = new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, '_ctor', 0));
    FormalParameterList parameters = _createEmptyFormalParameterList();
    FunctionBody body = _createExpressionFunctionBody(className);
    return new MethodDeclaration(comment, metadata, externalKeyword, modifierKeyword, returnType, propertyKeyword, operatorKeyword, name, parameters, body);
  }

  ExpressionFunctionBody _createExpressionFunctionBody(String className) {
    Token asyncKeyword = null;
    Token functionDefinition = new Token(TokenType.FUNCTION, 0);
    Expression expression = _createInstanceCreationExpression(className, '_');
    Token semicolon = new Token(TokenType.SEMICOLON, 0);
    return new ExpressionFunctionBody(asyncKeyword, functionDefinition, expression, semicolon);
  }

  InstanceCreationExpression _createInstanceCreationExpression(String className, String constructorName, [List<Expression> arguments = null]) {
    var newToken = new KeywordToken(Keyword.NEW, 0);
    Token period = new Token(TokenType.PERIOD, 0);
    SimpleIdentifier name = new SimpleIdentifier(new StringToken(TokenType.STRING, constructorName, 0));
    ArgumentList argumentList = new ArgumentList(new BeginToken(TokenType.OPEN_PAREN, 0), arguments , new Token(TokenType.CLOSE_PAREN, 0));
    return new InstanceCreationExpression(newToken, new ConstructorName(new TypeName(new SimpleIdentifier(new StringToken(TokenType.STRING, className, 0)), null), period, name), argumentList);
  }

  ConstructorDeclaration _createFactoryConstructor(String className) {
    var comment = null;
    var metadata = null;
    var externalKeyword = null;
    var constKeyword = null;
    var factoryKeyword = new KeywordToken(Keyword.FACTORY, 0);
    var returnType = new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, className, 0));
    var period = null;
    var name = null;
    var parameters = _createEmptyFormalParameterList();
    var separator = null;
    var initializers = null;
    var redirectedConstructor = null;
    var body = new BlockFunctionBody(null, null, _createBlock(className));

    return new ConstructorDeclaration(comment, metadata, externalKeyword, constKeyword, factoryKeyword, returnType, period, name, parameters, separator, initializers, redirectedConstructor, body);
  }

  Block _createBlock(String className) {
    Token leftBracket = new BeginToken(TokenType.OPEN_CURLY_BRACKET, 0);
    List<Statement> statements = <Statement>[];
    List<VariableDeclaration> variables = <VariableDeclaration>[];
    variables.add(_createVariableDeclaration(className));
    VariableDeclarationList variableList = new VariableDeclarationList(null, null, null, new TypeName(new SimpleIdentifier(new StringToken(TokenType.STRING, className, 0)), null), variables);
    var variableDeclarationStatement = new VariableDeclarationStatement(variableList, new Token(TokenType.SEMICOLON, 0));
    Expression expression = new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, 'pooledComponent', 0));
    var returnStatement = new ReturnStatement(new KeywordToken(Keyword.RETURN, 0), expression, new Token(TokenType.SEMICOLON, 0));
    statements.add(variableDeclarationStatement);
    statements.add(returnStatement);
    Token rightBracket = new Token(TokenType.CLOSE_CURLY_BRACKET, 0);
    return new Block(leftBracket, statements, rightBracket);
  }

  VariableDeclaration _createVariableDeclaration(String className) {
    Comment comment = null;
    List<Annotation> metadata = null;
    SimpleIdentifier name = new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, 'pooledComponent', 0));
    Token equals = new Token(TokenType.EQ, 0);
    List<Expression> arguments = <Expression>[];
    arguments.add(new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, className, 0)));
    arguments.add(new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, '_ctor', 0)));
    Expression initializer = _createInstanceCreationExpression('Pooled', 'of', arguments);
    return new VariableDeclaration(comment, metadata, name, equals, initializer);
  }

  ConstructorDeclaration _createHiddenConstructor(String className) {
    var comment = null;
    var metadata = null;
    var externalKeyword = null;
    var constKeyword = null;
    var factoryKeyword = null;
    var returnType = new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, className, 0));
    var period = new Token(TokenType.PERIOD, 0);
    var name = new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, '_', 0));
    var parameters = _createEmptyFormalParameterList();
    var separator = null;
    var initializers = null;
    var redirectedConstructor = null;
    var body = new EmptyFunctionBody(new Token(TokenType.SEMICOLON, 0));

    return new ConstructorDeclaration(comment, metadata, externalKeyword, constKeyword, factoryKeyword, returnType, period, name, parameters, separator, initializers, redirectedConstructor, body);
  }

  FormalParameterList _createEmptyFormalParameterList() {
    Token leftParenthesis = new BeginToken(TokenType.OPEN_PAREN, 0);
    List<FormalParameter> parameters = [];
    Token leftDelimiter = null;
    Token rightDelimiter = null;
    Token rightParenthesis = new StringToken(TokenType.CLOSE_PAREN, ')', 0);
    return new FormalParameterList(leftParenthesis, parameters, leftDelimiter, rightDelimiter, rightParenthesis);
  }


}
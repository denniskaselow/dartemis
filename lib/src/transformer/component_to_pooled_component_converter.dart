part of transformer;


class ComponentToPooledComponentConverter {

  void convert(ClassDeclaration unit) {
    var className = unit.name.name;
    unit.extendsClause.superclass.name = new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, 'PooledComponent', 0));

    var constructorVisitor = new _ComponentConstructorToFactoryConstructorConvertingAstVisitor();
    unit.visitChildren(constructorVisitor);

    if (constructorVisitor._count == 0) {
      unit.members.add(_createFactoryConstructor(className));
    }
    unit.members.add(_createStaticConstructorMethod(className));
    unit.members.add(_createHiddenConstructor(className));
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
    FormalParameterList parameters = _createFormalParameterList();
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

  ConstructorDeclaration _createFactoryConstructor(String className) {
    var comment = null;
    var metadata = null;
    var externalKeyword = null;
    var constKeyword = null;
    var factoryKeyword = new KeywordToken(Keyword.FACTORY, 0);
    var returnType = new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, className, 0));
    var period = null;
    var name = null;
    var parameters = _createFormalParameterList();
    var separator = null;
    var initializers = null;
    var redirectedConstructor = null;
    var body = new BlockFunctionBody(null, null, _createPooledComponentCreationBlock(className));

    return new ConstructorDeclaration(comment, metadata, externalKeyword, constKeyword, factoryKeyword, returnType, period, name, parameters, separator, initializers, redirectedConstructor, body);
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
    var parameters = _createFormalParameterList();
    var separator = null;
    var initializers = null;
    var redirectedConstructor = null;
    var body = new EmptyFunctionBody(new Token(TokenType.SEMICOLON, 0));

    return new ConstructorDeclaration(comment, metadata, externalKeyword, constKeyword, factoryKeyword, returnType, period, name, parameters, separator, initializers, redirectedConstructor, body);
  }

}

FormalParameterList _createFormalParameterList([List<FormalParameter> parameters = const <FormalParameter>[]]) {
  Token leftParenthesis = new BeginToken(TokenType.OPEN_PAREN, 0);
  Token leftDelimiter = null;
  Token rightDelimiter = null;
  Token rightParenthesis = new StringToken(TokenType.CLOSE_PAREN, ')', 0);
  return new FormalParameterList(leftParenthesis, parameters, leftDelimiter, rightDelimiter, rightParenthesis);
}

Block _createPooledComponentCreationBlock(String className, [List<Statement> fieldAssignments = const <Statement>[]]) {
  Token leftBracket = new BeginToken(TokenType.OPEN_CURLY_BRACKET, 0);
  List<Statement> statements = <Statement>[];
  List<VariableDeclaration> variables = <VariableDeclaration>[];
  variables.add(_createVariableDeclaration(className));
  VariableDeclarationList variableList = new VariableDeclarationList(null, null, null, new TypeName(new SimpleIdentifier(new StringToken(TokenType.STRING, className, 0)), null), variables);
  var variableDeclarationStatement = new VariableDeclarationStatement(variableList, new Token(TokenType.SEMICOLON, 0));
  Expression expression = new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, 'pooledComponent', 0));
  var returnStatement = new ReturnStatement(new KeywordToken(Keyword.RETURN, 0), expression, new Token(TokenType.SEMICOLON, 0));
  statements.add(variableDeclarationStatement);
  fieldAssignments.forEach((statement) => statements.add(statement));
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

InstanceCreationExpression _createInstanceCreationExpression(String className, String constructorName, [List<Expression> arguments = null]) {
  var newToken = new KeywordToken(Keyword.NEW, 0);
  Token period = new Token(TokenType.PERIOD, 0);
  SimpleIdentifier name = new SimpleIdentifier(new StringToken(TokenType.STRING, constructorName, 0));
  ArgumentList argumentList = new ArgumentList(new BeginToken(TokenType.OPEN_PAREN, 0), arguments , new Token(TokenType.CLOSE_PAREN, 0));
  return new InstanceCreationExpression(newToken, new ConstructorName(new TypeName(new SimpleIdentifier(new StringToken(TokenType.STRING, className, 0)), null), period, name), argumentList);
}

class _ComponentConstructorToFactoryConstructorConvertingAstVisitor extends SimpleAstVisitor {
  int _count = 0;
  _ComponentConstructorToFactoryConstructorConvertingAstVisitor();

  @override
  visitConstructorDeclaration(ConstructorDeclaration node) {
    node.factoryKeyword = new KeywordToken(Keyword.FACTORY, 0);
    var formalParameters = <FormalParameter>[];
    var assignmentStatements = <Statement>[];
    node.parameters.parameters.forEach((parameter) {
      bool addStatement = true;
      var modifiedParameter = new SimpleFormalParameter(null, null, null, null, new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, parameter.identifier.name, 0)));
      if (parameter is FieldFormalParameter) {
        formalParameters.add(modifiedParameter);
      } else if (parameter is DefaultFormalParameter) {
        if (parameter.parameter is FieldFormalParameter) {
          parameter.parameter = modifiedParameter;
        }
        formalParameters.add(parameter);
      } else if (parameter is SimpleFormalParameter) {
        formalParameters.add(parameter);
        addStatement = false;
      } else {
        throw '${parameter.runtimeType} is not yet supported as a parameter for a Component, please open an issue at https://github.com/denniskaselow/dartemis/issues';
      }
      if (addStatement) {
        Expression leftHandSide = new PrefixedIdentifier(new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, 'pooledComponent', 0)), new Token(TokenType.PERIOD, 0), new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, parameter.identifier.name, 0)));
        Token operator = new Token(TokenType.EQ, 0);
        Expression rightHandSide = new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, parameter.identifier.name, 0));
        Token semicolon = new Token(TokenType.SEMICOLON, 0);
        assignmentStatements.add(new ExpressionStatement(new AssignmentExpression(leftHandSide, operator, rightHandSide), semicolon));
      }
    });
    node.initializers.forEach((ConstructorFieldInitializer initializer) {
      Expression leftHandSide = new PrefixedIdentifier(new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, 'pooledComponent', 0)), new Token(TokenType.PERIOD, 0), new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, initializer.fieldName.name, 0)));
      Token operator = new Token(TokenType.EQ, 0);
      Token semicolon = new Token(TokenType.SEMICOLON, 0);
      assignmentStatements.add(new ExpressionStatement(new AssignmentExpression(leftHandSide, operator, initializer.expression), semicolon));
    });
    node.parameters = _createFormalParameterList(formalParameters);
    node.body = new BlockFunctionBody(null, null, _createPooledComponentCreationBlock(node.returnType.name, assignmentStatements));
    node.initializers.clear();
    _count++;
  }
}
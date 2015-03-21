part of transformer;


class ComponentToPooledComponentConverter {

  bool convert(ClassDeclaration unit) {
    var className = unit.name.name;
    unit.extendsClause.superclass.name = AstFactory.identifier3('PooledComponent');

    var constructorVisitor = new _ComponentConstructorToFactoryConstructorConvertingAstVisitor();
    unit.visitChildren(constructorVisitor);

    if (constructorVisitor._count == 0) {
      unit.members.add(_createFactoryConstructor(className));
    }
    unit.members.add(_createStaticConstructorMethod(className));
    unit.members.add(_createHiddenConstructor(className));
    return true;
  }

  MethodDeclaration _createStaticConstructorMethod(String className) {
    TypeName returnType = new TypeName(AstFactory.identifier3(className), null);
    SimpleIdentifier name = AstFactory.identifier3('_ctor');
    FormalParameterList parameters = _createFormalParameterList();
    FunctionBody body = _createExpressionFunctionBody(className);
    return AstFactory.methodDeclaration2(Keyword.STATIC, returnType, null, null, name, parameters, body);
  }

  ExpressionFunctionBody _createExpressionFunctionBody(String className) {
    Expression expression = _createInstanceCreationExpression(className, '_');
    return AstFactory.expressionFunctionBody(expression);
  }

  ConstructorDeclaration _createFactoryConstructor(String className) {
    var returnType = AstFactory.identifier3(className);
    var name = null;
    var parameters = _createFormalParameterList();
    var initializers = null;
    var body = new BlockFunctionBody(null, null, _createPooledComponentCreationBlock(className));
    return AstFactory.constructorDeclaration2(null, Keyword.FACTORY, returnType, name, parameters, initializers, body);
  }

  ConstructorDeclaration _createHiddenConstructor(String className) {
    var returnType = AstFactory.identifier3(className);
    var parameters = _createFormalParameterList();
    var body = AstFactory.emptyFunctionBody();
    return AstFactory.constructorDeclaration2(null, null, returnType, '_', parameters, null, body);
  }
}

FormalParameterList _createFormalParameterList([List<FormalParameter> parameters = const <FormalParameter>[]]) {
  return AstFactory.formalParameterList(parameters);
}

Block _createPooledComponentCreationBlock(String className, [List<Statement> fieldAssignments = const <Statement>[]]) {
  List<Statement> statements = <Statement>[];
  List<VariableDeclaration> variables = <VariableDeclaration>[];
  variables.add(_createVariableDeclaration(className));
  var variableDeclarationStatement = AstFactory.variableDeclarationStatement(null, AstFactory.typeName3(AstFactory.identifier3(className)), variables);
  Expression expression = AstFactory.identifier3('pooledComponent');
  var returnStatement = AstFactory.returnStatement2(expression);
  statements.add(variableDeclarationStatement);
  fieldAssignments.forEach((statement) => statements.add(statement));
  statements.add(returnStatement);
  return AstFactory.block(statements);
}

VariableDeclaration _createVariableDeclaration(String className) {
  List<Expression> arguments = <Expression>[];
  arguments.add(AstFactory.identifier3(className));
  arguments.add(AstFactory.identifier3('_ctor'));
  Expression initializer = _createInstanceCreationExpression('Pooled', 'of', arguments);
  return AstFactory.variableDeclaration2('pooledComponent', initializer);
}

InstanceCreationExpression _createInstanceCreationExpression(String className, String constructorName, [List<Expression> arguments = null]) {
  return AstFactory.instanceCreationExpression3(Keyword.NEW, AstFactory.typeName4(className), constructorName, arguments);
}

class _ComponentConstructorToFactoryConstructorConvertingAstVisitor extends SimpleAstVisitor {
  int _count = 0;
  _ComponentConstructorToFactoryConstructorConvertingAstVisitor();

  @override
  visitConstructorDeclaration(ConstructorDeclaration node) {
    node.factoryKeyword = TokenFactory.tokenFromKeyword(Keyword.FACTORY);
    var formalParameters = <FormalParameter>[];
    var assignmentStatements = <Statement>[];
    node.parameters.parameters.forEach((parameter) {
      bool addStatement = true;
      var modifiedParameter = AstFactory.simpleFormalParameter3(parameter.identifier.name);
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

        Expression leftHandSide = AstFactory.identifier5('pooledComponent', parameter.identifier.name);
        Expression rightHandSide = AstFactory.identifier3(parameter.identifier.name);
        assignmentStatements.add(AstFactory.expressionStatement(AstFactory.assignmentExpression(leftHandSide, TokenType.EQ, rightHandSide)));
      }
    });
    node.initializers.forEach((ConstructorFieldInitializer initializer) {
      Expression leftHandSide = AstFactory.identifier5('pooledComponent', initializer.fieldName.name);
      assignmentStatements.add(AstFactory.expressionStatement(AstFactory.assignmentExpression(leftHandSide, TokenType.EQ, initializer.expression)));
    });
    if (node.body is BlockFunctionBody) {
      node.body.visitChildren(new StatementVisitor());
      (node.body as BlockFunctionBody).block.statements.forEach((statement) {
        assignmentStatements.add(statement);
      });
    }
    node.parameters = _createFormalParameterList(formalParameters);
    node.body = AstFactory.blockFunctionBody(_createPooledComponentCreationBlock(node.returnType.name, assignmentStatements));
    node.initializers.clear();
    _count++;
  }
}

class StatementVisitor extends RecursiveAstVisitor {

  @override
  visitPropertyAccess(PropertyAccess node) {
    super.visitPropertyAccess(node);
    if (node.target is ThisExpression) {
      node.target = AstFactory.identifier3('pooledComponent');
    }
    return null;
  }
}
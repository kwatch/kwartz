<?php
// vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4:

// $Id$

require_once('Kwartz/KwartzNode.php');

// namespace Kwartz {

/*
 * a visitor class to traverse node tree
 */
class KwartzVisitor {
    function visit_unary_expr($expr) {
        return $expr;
    }
    function visit_binary_expr($expr) {
        return $expr;
    }
    function visit_property_expr($expr) {
        return $expr;
    }
    function visit_function_expr($expr) {
        return $expr;
    }
    function visit_conditional_expr($expr) {
        return $expr;
    }
    
    function visit_leaf_expr($expr) {
        return $expr;
    }
    
    function visit_variable_expr($expr) {
        return $this->visit_leaf_expr($expr);
    }
    function visit_string_expr($expr) {
        return $this->visit_leaf_expr($expr);
    }
    function visit_numeric_expr($expr) {
        return $this->visit_leaf_expr($expr);
    }
    function visit_boolean_expr($expr) {
        return $this->visit_leaf_expr($expr);
    }
    function visit_null_expr($expr) {
        return $this->visit_leaf_expr($expr);
    }
    
    function visit_print_stmt($stmt) {
        return $stmt;
    }
    function visit_set_stmt($stmt) {
        return $stmt;
    }
    function visit_if_stmt($stmt) {
        return $stmt;
    }
    function visit_while_stmt($stmt) {
        return $stmt;
    }
    function visit_foreach_stmt($stmt) {
        return $stmt;
    }
    function visit_macro_stmt($stmt) {
        return $stmt;
    }
    function visit_expand_stmt($stmt) {
        return $stmt;
    }
    function visit_block_stmt($stmt) {
        return $stmt;
    }
    function visit_rawcode_stmt($stmt) {
        return $stmt;
    }
}


/*
 * a visitor to copy an instance of KwartzNode
 */
class KwartzDeepCopyVisitor extends KwartzVisitor {

    //
    // Expressions
    //
    function visit_unary_expr($expr) {
        $child = $expr->child()->accept($this);
        return new KwartzUnaryExpression($expr->token(), $child);
    }
    function visit_binary_expr($expr) {
        $left  = $expr->left()->accept($this);
        $right = $expr->right()->accept($this);
        return new KwartzBinaryExpression($expr->token(), $left, $right);
    }
    function visit_property_expr($expr) {
        $object = $expr->object->accept($this);
        if ($expr->arglist) {
            $arglist = array();
            foreach ($arglist as $arg) {
                $arglist[] = $arg->accept($this);
            }
        } else {
            $arglist = NULL;
        }
        return new KwartzPropertyExpression($expr->token(), $object, $expr->property(), $arglist);
    }
    function visit_function_expr($expr) {
        $list = array();
        foreach ($expr->arglist as $expr) {
            $list[] = $expr->accept($this);
        }
        return new KwartzFunctionExpression($expr->funcname, $list);
    }
    function visit_conditional_expr($expr) {
        $left  = $expr->left()->accept($this);
        $right = $expr->right()->accept($this);
        return new KwartzConditionalExpression($expr->token(), $expr->condition(), $left, $right);
    }
    
    function visit_leaf_expr($expr) {
        assert(false);
    }
    function visit_variable_expr($expr) {
        return new KwartzVariableExpression($expr->value());
    }
    function visit_string_expr($expr) {
        return new KwartzStringExpression($expr->value());
    }
    function visit_numeric_expr($expr) {
        return new KwartzNumericExpression($expr->value());
    }
    function visit_boolean_expr($expr) {
        return new KwartzBooleanExpression($expr->value());
    }
    function visit_null_expr($expr) {
        return new KwartzNullExpression($expr->value());
    }
    
    //
    // Statements
    //
    function visit_print_stmt($stmt) {
        $exprlist = array();
        foreach ($stmt->arglist() as $expr) {
            $exprlist[] = $expr->accept($this);
        }
        return new KwartzPrintStatement($exprlist);
    }
    function visit_set_stmt($stmt) {
        $assign_expr = $stmt->assign_expr()->accept($this);
        return new KwartzSetStatement($assign_expr);
    }
    function visit_if_stmt($stmt) {
        $cond_expr = $stmt->condition()->accept($this);
        $then_block = $stmt->then_block()->accept($this);
        $else_stmt  = $stmt->else_stmt() ? $stmt->else_stmt()->accept($this) : NULL;
        return new KwartzIfStatement($cond_expr, $then_block, $else_stmt);
    }
    function visit_while_stmt($stmt) {
        $cond_expr = $stmt->condition()->accept($this);
        $body_block = $stmt->body_block()->accept($this);
        return new KwartzWhileStatement($cond_expr, $body_block);
    }
    function visit_foreach_stmt($stmt) {
        $loopvar_expr = $stmt->loopvar_expr()->accept($this);
        $list_expr    = $stmt->list_expr()->accept($this);
        $body_block   = $stmt->body_block()->accept($this);
        return new KwartzForeachStatement($loopvar_expr, $list_expr, $body_block);
    }
    function visit_macro_stmt($stmt) {
        $macro_name = $stmt->macro_name();
        $body_block = $stmt->body_block()->accept($this);
        return new KwartzMacroStatement($macro_name, $body_block);
    }
    function visit_expand_stmt($stmt) {
        $macro_name = $stmt->macro_name();
        return new KwartzExpandStatement($macro_name);
    }
    function visit_block_stmt($block) {
        $stmt_list = arary();
        foreach ($block->statements() as $stmt) {
            $stmt_list[] = $stmt->accept($this);
        }
        return new KwartzBlockStatement($stmt_list);
    }
    function visit_rawcode_stmt($stmt) {
        $rawcode = $stmt->rawcode();
        new KwartzRawcodeStatement($rawcode);
    }
    
}

// }  // end of namespace Kwartz
?>
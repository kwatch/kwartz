<?php
// vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4:

// $Id$

require_once('Kwartz/KwartzNode.php');
require_once('Kwartz/KwartzVisitor.php');

//namespace Kwartz {

/**
 * analyze a node tree
 */
class KwartzAnalyzer {
    private $node;
    private $analyze_visitor;
    private $toppings;
    
    function __construct($node, $toppings=NULL) {
        if ($node->token() == '<<block>>') {
            $this->node = $node->rearrange();
        } else {
            $this->node = $node;
        }
        $this->toppings = $toppings ? $toppings : array();
        $this->analyze_visitor = new KwartzAnalyzeVisitor();
    }
    
    function topping($name) {
        if (array_key_exists($name, $this->toppings)) {
            return $this->toppings[$name];
        }
        return NULL;
    }
    
    function analyze() {
        $this->node->accept($this->analyze_visitor);
    }
    
    function global_vars() {
        return $this->analyze_visitor->global_vars();
    }
    function local_vars() {
        return $this->analyze_visitor->local_vars();
    }
    
    function result() {
        $warned_global_vars = array();
        $warned_local_vars  = array();
        $s = '';
        
        $s .= "global variable(s):";
        $hash = $this->global_vars();
        foreach ($hash as $name => $flag_warning) {
            $s .= " $name";
            if ($flag_warning) {
                $warned_global_vars[] = $name;
            }
        }
        $s .= "\n";
        
        $s .= "local variable(s): ";
        foreach ($this->local_vars() as $name => $flag_warning) {
            $s .= " $name";
            if ($flag_warning) {
                $warned_local_vars[] = $name;
            }
        }
        $s .= "\n";
        
        if (count($warned_global_vars) > 0) {
            $s .= "Warning: assigned global variable(s):";
            foreach ($warned_global_vars as $name) {
                $s .= " $name";
            }
            $s .= "\n";
        }
        if (count($warned_local_vars) > 0) {
            $s .= "Warning: uninitialized local variable(s):";
            foreach ($warned_local_vars as $name) {
                $s .= " $name";
            }
            $s .= "\n";
        }
        
        return $s;
    }
    
}


/**
 * helper class for KwartzAnalyzer
 */
class KwartzAnalyzeVisitor {
    private $global_vars;
    private $local_vars;
    private $macro_stmt_list;
    
    function __construct() {
        $this->global_vars = array();
        $this->local_vars = array();
        $this->macro_stmt_list = array();	// hash
    }
    
    function global_vars() { return $this->global_vars; }
    function local_vars()  { return $this->local_vars;  }
    
    function add_global_var($name, $flag_warning=FALSE) {
        $this->global_vars[$name] = $flag_warning;
    }
    
    function add_local_var($name, $flag_warning=FALSE) {
        $this->local_vars[$name] = $flag_warning;
    }
    
    function is_global_var($name) {
        return array_key_exists($name, $this->global_vars);
    }
    function is_local_var($name) {
        return array_key_exists($name, $this->local_vars);
    }

    //
    // Expression
    //
    function visit_unary_expr($expr) {
        $expr->child()->accept($this);
    }
    function visit_binary_expr($expr) {
        switch ($expr->token()) {
          case '=':
            $expr->right()->accept($this);
            $t = $expr->left()->token();
            if ($t == 'variable') {
                $name = $expr->left()->value();
                if ($this->is_global_var($name)) {
                    $this->add_global_var($name, TRUE);	  // assign to global var
                } elseif ($this->is_local_var($name)) {
                    // do nothing
                } else {
                    $this->add_local_var($name);
                }
            } elseif ($t == '[]' || $t == '[:]' || $t == '{}' || $t == '.') {
                $expr->left()->accept($this);
                $array = $expr->left()->left();
                if ($array->token() == 'variable') {
                    if ($this->is_global_var($array->value())) {
                        $this->add_global_var($array->value(), TRUE);
                    }
                }
            } else {
                $expr->left()->accept($this);
            }
            break;
            
          case '+=':  case '-=':	case '*=':  case '/=':	case '%=':  case '^=':	case '.+=':
            $expr->right()->accept($this);
            if ($expr->left()->token() == 'variable') {
                $name = $expr->left()->value();
                if ($this->is_global_var($name)) {
                    $this->add_global_var($name, TRUE);		// assign to global var
                    } elseif ($this->is_local_var($name)) {
                        // OK
                    } else {
                        $this->add_local_var($name, TRUE);	// uninitialized local var
                    }
            } else {
                $expr->left()->accept($this);
            }
            break;
            
          default:
            $expr->left()->accept($this);
            $expr->right()->accept($this);
        }
    }
    function visit_property_expr($expr) {
        $expr->object()->accept($this);
        $arglist = $expr->arglist();
        if ($arglist && count($arglist) > 0) {
            foreach ($arglist as $arg) {
                $arg->accept($this);
            }
        }
    }
    function visit_function_expr($expr) {
        foreach ($expr->arglist() as $expr) {
            $expr->accept($this);
        }
    }
    function visit_conditional_expr($expr) {
        $expr->condition()->accept($this);
        $expr->left()->accept($this);
        $expr->right()->accept($this);
    }
    
    function visit_leaf_expr($expr) {
        assert(false);
    }
    function visit_variable_expr($expr) {
        $name = $expr->value();
        if (! $this->is_global_var($name) && ! $this->is_local_var($name)) {
            $this->add_global_var($name);
        }
    }
    function visit_string_expr($expr) {
        return;
    }
    function visit_numeric_expr($expr) {
        return;
    }
    function visit_boolean_expr($expr) {
        return;
    }
    function visit_null_expr($expr) {
        return;
    }
    
    //
    // Statement
    //
    function visit_print_stmt($stmt) {
        foreach ($stmt->arglist() as $expr) {
            $expr->accept($this);
        }
    }
    function visit_set_stmt($stmt) {
        $stmt->assign_expr()->accept($this);
    }
    function visit_if_stmt($stmt) {
        $stmt->condition()->accept($this);
        $stmt->then_block()->accept($this);
        if ($stmt->else_stmt()) {
            $stmt->else_stmt()->accept($this);
        }
    }
    function visit_while_stmt($stmt) {
        $stmt->condition()->accept($this);
        $stmt->body_block()->accept($this);
    }
    function visit_foreach_stmt($stmt) {
        //$stmt->loopvar_expr()->accept($this);
        $stmt->list_expr()->accept($this);
        $name = $stmt->loopvar_expr()->value();
        if ($this->is_global_var($name)) {
            $this->add_global_var($name, TRUE);		// don't use global var as loop var
        } elseif ($this->is_local_var($name)) {
            // OK
        } else {
            $this->add_local_var($name);
        }
        $stmt->body_block()->accept($this);
    }
    function visit_macro_stmt($stmt) {
        $macro_name = $stmt->macro_name();
        $this->macro_stmt_list[$macro_name] = $stmt->body_block();
    }
    function visit_expand_stmt($stmt) {
        $macro_name = $stmt->macro_name();
        if (array_key_exists($macro_name, $this->macro_stmt_list)) {
            $body_block = $this->macro_stmt_list[$macro_name];
            $body_block->accept($this);
        } else {
            echo "*** warning: macro '{$macro_name}' not found.\n";
        }
    }
    function visit_block_stmt($block) {
        foreach ($block->statements() as $stmt) {
            $stmt->accept($this);
        }
    }
    function visit_rawcode_stmt($stmt) {
        return;
    }
    
}

//}  // end of namespace Kwartz
?>
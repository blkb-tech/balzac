/*
 * generated by Xtext 2.11.0
 */
package it.unica.tcs.generator

import it.unica.tcs.bitcoinTM.AfterTimeLock
import it.unica.tcs.bitcoinTM.AndExpression
import it.unica.tcs.bitcoinTM.ArithmeticSigned
import it.unica.tcs.bitcoinTM.Between
import it.unica.tcs.bitcoinTM.BooleanLiteral
import it.unica.tcs.bitcoinTM.BooleanNegation
import it.unica.tcs.bitcoinTM.Comparison
import it.unica.tcs.bitcoinTM.Expression
import it.unica.tcs.bitcoinTM.Hash
import it.unica.tcs.bitcoinTM.IfThenElse
import it.unica.tcs.bitcoinTM.Input
import it.unica.tcs.bitcoinTM.KeyDeclaration
import it.unica.tcs.bitcoinTM.Max
import it.unica.tcs.bitcoinTM.Min
import it.unica.tcs.bitcoinTM.Minus
import it.unica.tcs.bitcoinTM.NumberLiteral
import it.unica.tcs.bitcoinTM.OrExpression
import it.unica.tcs.bitcoinTM.Output
import it.unica.tcs.bitcoinTM.Plus
import it.unica.tcs.bitcoinTM.PrivateKey
import it.unica.tcs.bitcoinTM.PublicKey
import it.unica.tcs.bitcoinTM.Script
import it.unica.tcs.bitcoinTM.Signature
import it.unica.tcs.bitcoinTM.Size
import it.unica.tcs.bitcoinTM.StringLiteral
import it.unica.tcs.bitcoinTM.Versig
import org.bitcoinj.core.ECKey
import org.bitcoinj.core.Utils
import org.bitcoinj.script.ScriptBuilder
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import it.unica.tcs.bitcoinTM.SignatureType

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class BitcoinTMGenerator extends AbstractGenerator {

	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
//		fsa.generateFile('greetings.txt', 'People to greet: ' + 
//			resource.allContents
//				.filter(Greeting)
//				.map[name]
//				.join(', '))
	}
	
	
	
	def boolean isP2PKH(Script script) {
		var onlyOneSignatureParam = script.params.size==1 && (script.params.get(0).paramType instanceof SignatureType)
		var onlyVersig = script.exp instanceof Versig
		
		return onlyOneSignatureParam && onlyVersig
	}
	
	def boolean isOpReturn(Script script) {
		var noParam = script.params.size==0
		var onlyString = script.exp instanceof StringLiteral
		
		return noParam && onlyString
	}
	
	def boolean isP2SH(Script script) {
		return !script.isP2PKH && !script.isOpReturn
	}
	

	
	def dispatch String toBytecode(Input stmt) {
		var outIdx = stmt.txRef.idx
		var redeemedOutput = stmt.txRef.tx.body.outputs.get(outIdx).script;
		
		if (redeemedOutput.isP2PKH) {
			var sig = stmt.actual.exps.get(0) as Signature
			'''«sig.toBytecode» «sig.key.body.pub.toBytecode»'''
		}
		else if (redeemedOutput.isP2SH) {
			'''«stmt.actual.exps.map[e|e.toBytecode].join(" ")» «redeemedOutput.toBytecode»'''
		}
		else throw new UnsupportedOperationException
	}
	
	def dispatch String toBytecode(Script output) {
		/*
		 * TODO
		 */
		if (output.isP2PKH) {
			'''OP_DUP OP_HASH160 push(h(kaddress)) OP_EQUALVERIFY OP_CHECKSIG'''
		}
		else if (output.isP2SH) {
			'''OP_HASH160 push(h(λ (z1, ..., zn) . e)) OP_EQUAL'''
		}
		else if (output.isOpReturn) {
			var c = output.exp as StringLiteral
			'''OP_RETURN «c.toBytecode»'''
		}
		else throw new UnsupportedOperationException
	}
	
	
	def dispatch String toBytecode(Expression exp) {
		throw new UnsupportedOperationException
	}
	
	def dispatch String toBytecode(int exp) {
		throw new UnsupportedOperationException
	}
	
	def dispatch String toBytecode(KeyDeclaration stmt) {
		throw new UnsupportedOperationException
	}
	
	def dispatch String toBytecode(PrivateKey stmt) {
		throw new UnsupportedOperationException
	}
	
	def dispatch String toBytecode(PublicKey stmt) {
		// TODO: return the corresponding bitcoin address
		throw new UnsupportedOperationException
	}
	
	def dispatch String toBytecode(Hash hash) {
		'''«hash.value.toBytecode» OP_HASH160 '''
	}
	
	def dispatch String toBytecode(AfterTimeLock stmt) {
		'''«stmt.time.toBytecode» OP_CHECKLOCKVERIFY «stmt.continuation.toBytecode» '''
	}
	
	def dispatch String toBytecode(AndExpression stmt) {
		'''«stmt.left.toBytecode» «stmt.right.toBytecode» OP_BOOLAND '''
	}

	def dispatch String toBytecode(OrExpression stmt) {
		'''«stmt.left.toBytecode» «stmt.right.toBytecode» OP_BOOLOR '''
	}

	def dispatch String toBytecode(Plus stmt) {
		'''«stmt.left.toBytecode» «stmt.right.toBytecode» OP_ADD '''
	}
	
	def dispatch String toBytecode(Minus stmt) {
		'''«stmt.left.toBytecode» «stmt.right.toBytecode» OP_SUB '''
	}
	
	def dispatch String toBytecode(Max stmt) {
		'''«stmt.left.toBytecode» «stmt.right.toBytecode» OP_MAX '''
	}
	
	def dispatch String toBytecode(Min stmt) {
		'''«stmt.left.toBytecode» «stmt.right.toBytecode» OP_MIN '''
	}
	
	def dispatch String toBytecode(Size stmt) {
		'''«stmt.value.toBytecode» OP_SIZE '''
	}
	
	def dispatch String toBytecode(BooleanNegation stmt) {
		'''«stmt.exp.toBytecode» OP_NOT '''
	}
	
	def dispatch String toBytecode(ArithmeticSigned stmt) {
		'''«stmt.exp.toBytecode» OP_NEGATE '''
	}
	
	def dispatch String toBytecode(Between stmt) {
		'''«stmt.value.toBytecode» «stmt.left.toBytecode» «stmt.right.toBytecode» OP_WITHIN '''
	}
	
	def dispatch String toBytecode(Comparison stmt) {
		var String opcode
		
		switch (stmt.op) {
			case "<" : opcode = "OP_LESSTHAN"
			case ">" : opcode = "OP_GREATERTHAN"
			case "<=": opcode = "OP_LESSTHANOREQUAL"
			case ">=": opcode = "OP_GREATERTHANOREQUAL"
		}
		
		'''«stmt.left.toBytecode» «stmt.right.toBytecode» «opcode» '''
	}
	
	def dispatch String toBytecode(IfThenElse stmt) {
		'''«stmt.^if.toBytecode» OP_IF «stmt.then.toBytecode» OP_ELSE «stmt.^else.toBytecode» OP_ENDIF '''
	}
	
	def dispatch String toBytecode(Versig stmt) {
		if (stmt.pubkeys.size==1) {
			'''«stmt.signatures.get(0).toBytecode» «stmt.pubkeys.get(0).body.pub.toBytecode» OP_CHECKSIG '''
		}
		else {
			'''OP_0 «stmt.signatures.size.toBytecode»''' + 
			'''«stmt.signatures.map[s|s.toBytecode].join(" ")» ''' + 
			'''«stmt.pubkeys.size.toBytecode»''' + 
			'''«stmt.pubkeys.map[s|s.toBytecode].join(" ")» ''' + 
			'''OP_CHECKMULTISIG '''
		}
	}
	
	def dispatch String toBytecode(NumberLiteral n) {
		new ScriptBuilder().number(n.value).build().toString
	}
	
	def dispatch String toBytecode(BooleanLiteral n) {
		new ScriptBuilder().number(if (n.isTrue) 1 else 0).build().toString
	}
	
	def dispatch String toBytecode(StringLiteral s) {
		new ScriptBuilder().data(s.value.bytes).build().toString
	}
	
	def dispatch String toBytecode(Signature stmt) {
		/*
		 * TODO
		 */
		var pvtKey = stmt.key.body.pvt.value
		
		var key = ECKey.fromPrivate(Utils.parseAsHexOrBase58(pvtKey));
		var tx = null;	// TODO: get transaction to sign
		
		
		'''<sig «stmt.key.name» «stmt.modifier»> '''
	}
	
}

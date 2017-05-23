/*
 * generated by Xtext 2.11.0
 */
package it.unica.tcs

import it.unica.tcs.xsemantics.BitcoinTMStringRepresentation
import it.unica.tcs.xsemantics.validation.BitcoinTMTypeSystemValidator
import it.xsemantics.runtime.StringRepresentation
import org.eclipse.xtext.service.SingletonBinding

/**
 * Use this class to register components to be used at runtime / without the Equinox extension registry.
 */
class BitcoinTMRuntimeModule extends AbstractBitcoinTMRuntimeModule {
	
	def Class<? extends StringRepresentation> bindStringRepresentation() {
		return BitcoinTMStringRepresentation;
	}
	
	@SingletonBinding(eager=true)
	def Class<? extends BitcoinTMTypeSystemValidator> bindBitcoinTMTypeSystemValidator() {
		return BitcoinTMTypeSystemValidator;
	}
    
}

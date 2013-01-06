//
//  FileMgr.m
//  FileExample
//
//  Created by Jesus Renero Quintero on 11/12/10.
//  Copyright 2010 Telefonica I+D. All rights reserved.
//

#import "FileMgr.h"

@implementation FileMgr
@synthesize myFileManager, cwd;

/*
 Initialization function: simply gets the current working directory (cwd)
 and sets up the file manager objet to be used throughout the class (myFileManager).
 */
- (id)init 
{
	self = [super init];
	if (self != nil) {
		myFileManager = [NSFileManager defaultManager];
		cwd = [myFileManager currentDirectoryPath];
		
		// Inicializacion de variables que utilizo dentro del objeto.
		bufferPosition = 0;
		parserStateMachineStatus = 0;
		numLine = 1;
	}
	return self;
}

/*
 This function checks that the file to be used is OK to be used.
*/
- (BOOL)fileExists:(NSString *)whichPath 
{	
	if ([myFileManager fileExistsAtPath:whichPath] == YES) {
		path = whichPath;
		return YES;
	}
	else {
		return NO;
	}
}

/*
 This method puts all the data from file into a buffer in memory which
 is returned. If anything goes wrong it returns nil.
 */
- (NSString *)suckData
{
	// unmutable buffer where storing the data read from the file.
	NSData *data;	
	
	// Grab all the contents of the file to memory.
	data = [myFileManager contentsAtPath:path];
	// Did anything go wrong?
	if (data == nil) {
		NSLog (@"File read failed!\n");
        return nil;
	}
	// Se convierte el flujo NSData original del fichero en otro codificado como ASCII Strings.
	NSString *output = [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];

	[data release];
	
	return [FileMgr beautify:output flag:NO];
}

/*
 * Windows uses LF+CR
 * Apple uses only LF (10)
 * Unix uses only CR (13)
 */
+ (NSString *)beautify:(NSString *)input flag:(BOOL)verbose
{
	NSMutableString *output = [NSMutableString stringWithCapacity:[input length]];
	NSUInteger i,length;
	unichar c,d;
	
	// Imprimo la tabla ASCII de vez en cuando para comprobar caracteres.
	//[FileMgr printASCIITable];
	
	// Tomo la longitud total del buffer - 1, porque al final tiene el EOF.
	length = [input length]-1;
	for (i=0; i<length; i++) 
	{
		// Recojo en la variable "c" el caracter en la posicion actual "i".
		// y en "d" el caracter en la posición siguiente, para poder construir
		// mi maquina de estados
		c = [input characterAtIndex:i];
		d = [input characterAtIndex:i+1];
		
		/*
		 0. 'c' = caracter actual
		 1. Si 'c' = LF, miro el siguiente caracter
		 2.		Si el siguiente caracter es un CR,
		 3.			Avanzar el bucle para que ignore el CR
		 4.		SALTAR AL PASO 9
		 5.	Si 'c' = CR, miro el siguiente caracter		
		 6.		Si el siguiente caracter es un LF
		 7.			Avanzar el bucle para que ignore el LF
		 8.		'c' = CR. SALTAR AL PASO 9
		 9. Guardar 'c' en el buffer de respuesta.
		 */
		switch (c) 
		{
			case 10:
				if(d == 13) { i++; }
				if(verbose) printf("%c", c);
				[output appendFormat:@"%C", c];
				break;
			case 13:
				if(d == 10) { i++; }
				c = 10;
				if(verbose) printf("%c", c);
				[output appendFormat:@"%C", c];
				break;
			// En esta parte solo me quedo con los caracteres que me interesan.
			// Intento eliminar los no imprimibles.
			default:
				// Los caracteres vallidos por pantalla son los que estan entre el 32 y el 126.
				// Si no esta en ese rango es un caracter raro de Windows o de vete a saber qué
				if ( ((c>=32)&&(c<=126)))
				{
					if(verbose) printf("%c", c);
					[output appendFormat:@"%C", c];
				}
				// Estas son las vocales con acento y consonantes tipo ç, q debo guardar.
				else if ((c>=128)&&(c<=165)) {
					if(verbose) printf("%c", c);
					[output appendFormat:@"%C", c];
				}
				else
				{
					if(verbose) printf("{%d:%c}", c, c);
				} 
				break;
		}
	}
	if(verbose) printf("\n\n--\n\n");
	return output;
}

/*
 Recorre el buffer que se le pasa como argumento separando
 todos los campos por el separador ";" y los va metiendo en 
 un objeto "Entry", dentro de cada campo.
 Guarda posición del buffer en la que esta, con lo que se 
 le llama de forma iterativa hasta que se llega al final del
 buffer, y entonces devuelve "NIL".
 */
- (Entry *)getNextEntry:(NSString *)buffer
{
	NSMutableString *tmpBuffer;
	Entry *entry = [[Entry alloc] init];
	BOOL EOL = FALSE;
	unichar c;
	unichar fieldSeparator;
	NSMutableString* tmp;
	NSRange wholeShebang;
	
	// Estoy atento a no pasarme de la longitud del buffer.
	int length = [buffer length]-1;
	if (bufferPosition > length) return nil;
	
	// Utilizo est buffer temporal de 1024 para meter cada
	// campo que saco del otro buffer.
	tmpBuffer = [NSMutableString stringWithCapacity:1024]; 

	// Itero hasta que me encuentre el final de la linea o del buffer.
	while ((bufferPosition <= length) && (!EOL))
	{
		c = [buffer characterAtIndex:bufferPosition];
		
		// lo que determina cuando parar de leer del buffer es el 
		// primer caracter de cada campo. Si son comillas es porque
		// puede haber comas dentro, y entonces, no tengo que parar
		// hasta encontrar otras comillas...
		if (c == '"') {
			fieldSeparator = c;
		} else {
			fieldSeparator = ',';
		}
		
		// Si la linea empieza por un caracter valido, empiezo a procesar.
		if ( (([FileMgr isValidCharacter:c]) && (parserStateMachineStatus == 0)) ||
			  (parserStateMachineStatus > 0) ) 
		{
			do {
				[tmpBuffer appendFormat:@"%C",c];
				bufferPosition++;
				c = [buffer characterAtIndex:bufferPosition];
			} 
			while ((c != fieldSeparator) && (c != 10) && (bufferPosition < length));
			
			// Si me he parado en las comillas, tengo que incorporarlas al buffer temporal.
			if ((fieldSeparator == '"') && (bufferPosition < length)) {
				[tmpBuffer appendFormat:@"%C",c];
				bufferPosition++;
				c = [buffer characterAtIndex:bufferPosition];
			}
			
			bufferPosition++;
			switch (parserStateMachineStatus) 
			{
				case 0:
					entry.fechaOperacion = [tmpBuffer copy];
					[tmpBuffer setString:@""];
					parserStateMachineStatus++;
					break;
				case 1:
					entry.fechaValor = [tmpBuffer copy];
					[tmpBuffer setString:@""];
					parserStateMachineStatus++;
					break;
				case 2:
					// Si me he parado en las comillas, tengo que incorporarlas al buffer temporal.
					if ((fieldSeparator == '"') && (bufferPosition < length)) {
						// tengo que quitarle las comillas a lo capturado
						tmp = [NSMutableString stringWithString:tmpBuffer];
						wholeShebang = NSMakeRange(0, [tmp length]);
						[tmp replaceOccurrencesOfString:@"\"" withString:@"" 
												options:0 range:wholeShebang];				
						entry.concepto = [tmp copy];
					}
					else {
						entry.concepto = [tmpBuffer copy];
					}
					
					// Limpio el buffer temporal que uso para meter lo que capturo.
					[tmpBuffer setString:@""];
					parserStateMachineStatus++;
					
					break;
				case 3:
					if (fieldSeparator == '"') // le quito al buffer las comillas del ppio y del final.
					{
						// tengo que quitarle las comillas a lo capturado
						tmp = [NSMutableString stringWithString:tmpBuffer];
						wholeShebang = NSMakeRange(0, [tmp length]);
						[tmp replaceOccurrencesOfString:@"\"" withString:@"" 
											options:0 range:wholeShebang];
					
						entry.importe = (NSNumber *)[FileMgr 
												 stringToNumber:(NSString *)[NSString stringWithString:tmp] ];
					} else {
						entry.importe = (NSNumber *)[FileMgr 
													 stringToNumber:(NSString *)tmpBuffer ];
					}
					
					[tmpBuffer setString:@""];
					parserStateMachineStatus++;
					break;
				case 4:
					if (fieldSeparator == '"') // le quito al buffer las comillas del ppio y del final.
					{
						// tengo que quitarle las comillas a lo capturado
						tmp = [NSMutableString stringWithString:tmpBuffer];
						wholeShebang = NSMakeRange(0, [tmp length]);
						[tmp replaceOccurrencesOfString:@"\"" withString:@"" 
												options:0 range:wholeShebang];
						entry.saldo = (NSNumber *)[FileMgr
												   stringToNumber:(NSString *) [NSString stringWithString:tmp] ];
					}
					else {
						entry.saldo = (NSNumber *)[FileMgr
												   stringToNumber:(NSString *) tmpBuffer ];
					}

					[tmpBuffer setString:@""];
					parserStateMachineStatus = 0;
					numLine++;
					EOL = YES;
					break;					
				default:
					break;
			}
		}
		else // Me salto esta linea.
		{
			NSLog(@"Skip line %d due to incorrect format.", numLine);
			do {
				bufferPosition++;
				if (bufferPosition >= length) continue;
				c = [buffer characterAtIndex:bufferPosition];
			} while ((c != 10) && (bufferPosition < length));
			bufferPosition++;
			numLine++;
		}
	}
	
	return entry;
}

// Devuelve YES si el caracter que se le pasa es un numero,
// el signo "+" o el signo "-", o las dobles comillas \"
+ (BOOL)isValidCharacter:(unichar)c
{
	if ( ((c>=48)&&(c<=57)) || (c==43) || (c==45) || (c==34))
	{
		return YES;
	}
	return NO;
}

// Convierte un string a un numero, teniendo en cuenta el 
// locale... hardcoded.
+ (NSNumber *)stringToNumber:(NSString *)tempStr
{
	// localization allows other thousands separators, also.
	NSNumberFormatter * myNumFormatter = [[NSNumberFormatter alloc] init];
	NSLocale *esLocale = [[[NSLocale alloc] initWithLocaleIdentifier:@"es_ES"] autorelease];
	[myNumFormatter setLocale:esLocale]; // happen by default?
	[myNumFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	// next line is very important!
	[myNumFormatter setNumberStyle:NSNumberFormatterDecimalStyle]; // crucial
	
	NSNumber *tempNum = [myNumFormatter numberFromString:tempStr];
	//NSLog(@"string '%@' gives NSNumber '%@' with floatValue '%f'", 
	//	  tempStr, tempNum, [tempNum floatValue]);
	[myNumFormatter release];
	return tempNum;
}

// Imprime una tabla ASCII simple.
+ (void)printASCIITable
{
	int i,j;
	for (i=32;i<168;i+=8) { 
		for(int j=i;j<i+8;j++) printf (" %c ", j);
		printf("\t");
		for(j=i;j<i+8;j++) printf ("%03d ", j);
		printf("\n");
	}	
}

- (uint) getNumLines
{
	return numLine;
}

@end

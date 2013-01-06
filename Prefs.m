//
//  Prefs.m
//  NSUserDefaults
//
//  Created by Jesus Renero Quintero on 27/2/11.
//  Copyright 2013 Jesus Renero Quintero. All rights reserved.
//

/*
 
 Preferencias: "categories" (NSUserDefaults) -> Array de categorias (NSData): 
 @"categories" -> @"Casa", @"Supermercados", @"Viajes", ...
 
 Empaquetamiento/Desempaquetamiento: 
 data = [NSKeyedArchiver archivedDataWithRootObject:array];
 array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
 
 Para cada categoria (una prefrencia NSUserDefault), obtenemos un array de strings
 con los tags que definen esa categoria
 @"Casa" -> @"VERDECORA",@"LIQUIDACION",@"SECURITAS DIRECT",@"PERIODICA",@"PRESTAMO",@"IKEA"
 
 Todo ello empaquetando y desempaquetando con NSKeyedArchiver y NSKeyedUnarchiver
 
 */

#import <stdarg.h>
#import <Cocoa/Cocoa.h>
#import "Prefs.h"
#import "Match.h"


NSInteger countedSort(id obj1, id obj2, void *context) {
    NSCountedSet *countedSet = context;
    NSUInteger obj1Count = [countedSet countForObject:obj1];
    NSUInteger obj2Count = [countedSet countForObject:obj2];
	
    if (obj1Count > obj2Count) return NSOrderedAscending;
    else if (obj1Count < obj2Count) return NSOrderedDescending;
    return NSOrderedSame;
}

void LogIt (NSString *format, ...)
{
    va_list args;
    va_start (args, format);
    NSString *string;
    string = [[NSString alloc] initWithFormat: format  arguments: args];
    va_end (args);
    fprintf (stderr, "%s\n", [string UTF8String]);
    [string release];	
} // LogIt


@implementation Prefs


- (id)init {
	self = [super init];
	if (self != nil) {
		prefs = [NSUserDefaults standardUserDefaults];
	}
	return self;
}

/*
 
 MIRAR EN http://www.tiendas-espana.es/
 
 */
- (int) defaultPrefs
{
	/**
	 --esta es la categorizacion que hacen en un programa similar para el iphone.
	 General
	 Kids
	 House
	 Amusement
	 Wardrobe
	 Groceries
	 Misc
	 Food
	 Payments
	 Transport
	 Utilities
	 Personal
	 iTunes
	 Auto
	 Vacation
	 */
	NSMutableArray *defaultCategoriesArray = [NSArray arrayWithObjects:
											  @"Casa", 
											  @"Supermercados", 
											  @"Viajes y Vacaciones",
											  @"Comisiones e Intereses", 
											  @"Impuestos",
											  @"Educacion", 
											  @"Coche y Transporte", 
											  @"Cajero Automatico",
											  @"Recibos",
											  @"Ingresos",
											  @"Transferencias",
											  @"Salud y Bienestar",
											  @"Ropa, Regalos y Shopping",
											  @"Ocio y Cultura",
											  @"Restaurantes",
											  @"Otros",
											  nil];
	NSMutableArray *Casa = [NSMutableArray arrayWithObjects:
							@"VERDECORA",@"LIQUIDACION",@"SECURITAS DIRECT",@"PERIODICA",@"PRESTAMO",@"IKEA",
							@"LEROY MERLIN", @"CMB ", @"TIEN 21",@"MEDIA MARKT",@"VINCON",@"TEXTURA",nil];
	NSMutableArray *Super = [NSMutableArray arrayWithObjects:
							 @"TODYMAS",@"AHORRAMAS",@"MERCADONA",@"CARREFOUR",@"CARNICERIA",@"ALCAMPO",
							 @"EROSKI",@"HIPERCOR",@"LIDL",nil];
	NSMutableArray *Viaje = [NSMutableArray arrayWithObjects:
							 @"VIAJE",@"POSADA",@"HOSTAL",@"HOTEL",@"AIRPORT",@"ALDEASA",@"AEROPUERTO",nil];
	NSMutableArray *Inter = [NSMutableArray arrayWithObjects:
							 @"RECIBO",@"BANCO",@"POPULAR",@"CUOTA",@"TARJETA",nil];
	NSMutableArray *Imp = [NSMutableArray arrayWithObjects:
						   @"IMPUESTO",@"RETENIDOS",nil];
	NSMutableArray *Edu = [NSMutableArray arrayWithObjects:
						   @"UNIV",@"EDUCACION",@"INGLAN",@"ARISTOS",nil];
	NSMutableArray *Tra = [NSMutableArray arrayWithObjects:
						   @"E.S.",@"U.S.",@"CLA ",@"AGIP ",@"E S ",@"MUTUA",@"AUTOMOV",@"AMISTOSINA",
						   @"NOVO MOTOR",@"NEUMATICO",@"ESTAC SERV",@"GASPAGAN",
						   @"M-45",@"RADIALES",@"METRO DE MADRID",@"APARCAMIENTO",@"PARKING",@"AUTOPISTA",
						   @"IBERPISTAS",nil];
	NSMutableArray *ATM = [NSMutableArray arrayWithObjects:
						   @"REINTEGRO",@"CAJERO",nil];
	NSMutableArray *Recib = [NSMutableArray arrayWithObjects:
							 @"RECIBO",@"TELEFONICA",nil];
	NSMutableArray *Ingr = [NSMutableArray arrayWithObjects:
							@"TELEFONICA",@"INGRESO",@"NÓMINA",@"ERICSSON",@"INVESTIGA",@"ABONO",nil];
	NSMutableArray *Trnsf = [NSMutableArray arrayWithObjects:@"TRANSFERENCIA", @"RECIBIDA", nil];
	NSMutableArray *Salud = [NSMutableArray arrayWithObjects:
							 @"DECATHLON",@"CORPORATE WELLNESS",@"PELUQUERIA",@"PELUQUER",@"OCCITANE",
							 @"FARMACIA",@"FCIA ",@"CLINICA",nil];
	NSMutableArray *Ropa = [NSMutableArray arrayWithObjects:
							@"CORTE",@"INGLES",@"HENNES",@"MAURITZ",@"ZARA",@"MASSIMO",@"DUTTI",@"TIMBERLAND", 
							@"COLUMBIA",@"PANAMA JACK",@"SFERA",@"RIP CURL",@"ZAPATERIA",@"ZAPATO",@"GEOX",
							@"NIKE",@"ADIDAS",@"KIDDY",@"REEBOK",@"MIRADA D VACA",@"LES BOUTONS",@"LORENTI",
							@"SPANTAJAPAROS",@"SHOPPING",@"REGALO",@"JUGUET",nil];
	NSMutableArray *Ocio = [NSMutableArray arrayWithObjects:
							@"CINE",@"FNAC",@"GAME",@"ITUNES",@"I-TUNES",@"FAUNIA", @"PARQUE DE ATRACCIONES",
							@"UGC ",@"TICK TACK TICKET",@"BOOK",@"EDITORIAL",@"GUITAR",@"MUSIC",
							@"ESPASA CALPE",@"NASSICA",@"DOS MARES",nil];
	NSMutableArray *Rest = [NSMutableArray arrayWithObjects:
							@"WOK",@"FOSTER",@"RODILLA",@"STARBUCKS",@"CAFE",@"HOLLYWOOD",@"VINCI",@"PARK",
							@"VIPS",@"GINOS",@"GINVIPS",@"RIBS PARQUE SUR",@"RESTAURACION",@"MC DONALDS",
							@"PIZZERIA",@"ARROCERIA",@"ARROZ",@"VAQUERIA",@"LOUSBURY",@"CUCO",@"IZOTZA LEKUA",nil];
	NSMutableArray *Other = [NSMutableArray arrayWithObjects:
							 @"PAYPAL",nil];
	
	NSMutableArray *defaultsTagsArray = [NSMutableArray arrayWithObjects:Casa,Super,Viaje,Inter,Imp,Edu,Tra,
										 ATM,Recib,Ingr,Trnsf,Salud,Ropa,Ocio,Rest,Other,nil];
	
	// Creo el diccionario que contiene para cada categoria, el array de "tags" que lo define.
	// Para la categoria "Casa", se asocia a: @"VERDECORA",@"LIQUIDACION",@"SECURITAS DIRECT",@"PERIODICA",@"PRESTAMO",@"IKEA"
	diccionario = [NSMutableDictionary dictionaryWithObjects:defaultsTagsArray forKeys:defaultCategoriesArray];
	
	// Empaqueto el array de categorias en un contenedor de datos generico "NSData"
	// que es el formato que aceptan las preferencias "NSUserDefaults".
	// Lo que creo es un atributo llamado "categories" que contiene el array de 
	// categorias. Solo sus nombres.
	NSData *data;
	data = [NSKeyedArchiver archivedDataWithRootObject:defaultCategoriesArray];
	[prefs setObject:data forKey:@"categories"];
	[data release];
	
	// Y ya por fin, lo que hago es crear otro monton de atributos: uno por cada categoria,
	// y estos seran los que contendran los tags. Habra un atributo llamado "Casa" que 
	// me devolvera un NSData con el array de tags. Los datos son un empaquetado binario del
	// array de tags.
	for (id key in diccionario) {
		data = [NSKeyedArchiver archivedDataWithRootObject:[diccionario objectForKey:key]];
		[prefs setObject:data forKey:key];
		[data release];
	}
	
	NSLog(@"Default prefs dictionary set.");
	[prefs synchronize];
	NSLog(@"Default prefs sync'ed");
	
	/*
	NSLog(@"Gonna release intermediate memory");
	[Casa release];
	[Super release];
	[Viaje release];
	[Inter release];
	[Imp release];
	[Edu release];
	[Dep release];
	[Tra release];
	[Coche release];
	[ATM release];
	[Recib release];
	[Ingr release];
	[Salud release];
	[Reg release];
	[Shop release];
	[Ropa release];
	[Ocio release];
	[Rest release];
	[Other release];
	[defaultCategoriesArray release];
	[defaultsTagsArray release];
	NSLog(@"Done!");
	 */
	
	return 0;
}

/*
 Esta funcion lee las preferencias de lo que haya en la estructura NSUserDefaults
 */
- (int)readPrefs
{
	NSData *data;
	NSMutableArray *array;
	
	NSLog(@"Reading user preferences...");
	
	[diccionario release];
	diccionario = [[NSMutableDictionary alloc] init];
	
	data = [prefs objectForKey:@"categories"];
	array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	for(int i=0; i<array.count; i++) 
	{
		NSData  *subdata  = [prefs objectForKey:[array objectAtIndex:i]];
		NSMutableArray *subarray = [NSKeyedUnarchiver unarchiveObjectWithData:subdata];
		
		[diccionario setObject:subarray forKey:[array objectAtIndex:i]];
		
		[subarray release];
		[subdata release];
	}
	
	[data release];
	[array release];
	
	NSLog(@"  DONE!");

	return 0;
}

/*
 Esta funcion actualiza el NSUserDefaults con lo ultimo que se haya cambiado en el diccionario.
 */
- (int)syncPrefs
{
	NSLog(@"Syncing user preferences...");
	
	NSData *data;
	// Take the keys from the updated dictionary.
	NSArray *categoriesArray = [diccionario allKeys];
	// Pack the array into the NSData structure.
	data = [NSKeyedArchiver archivedDataWithRootObject:categoriesArray];
	[prefs removeObjectForKey:@"categories"];
	[prefs setObject:data forKey:@"categories"];
	
	[data release];
	
	// Y ya por fin, lo que hago es crear otro monton de atributos: uno por cada categoria,
	// y estos seran los que contendran los tags. Habra un atributo llamado "Casa" que 
	// me devolvera un NSData con el array de tags. Los datos son un empaquetado binario del
	// array de tags.
	for (id key in diccionario) {
		data = [NSKeyedArchiver archivedDataWithRootObject:[diccionario objectForKey:key]];
		[prefs removeObjectForKey:key];
		[prefs setObject:data forKey:key];
		[data release];
	}
	
	[prefs synchronize];
	
	NSLog(@"  DONE!");
	
	return 0;
}

/* 
 Una funcion para convertir un set multidimensional de sets de matches en 
 un array de arrays de matches.
 */
-(int)storeInPrefs:(NSMutableSet *)conflictsSet
{
	NSMutableArray *array = [[NSMutableArray alloc] init];
	NSMutableSet *subset;
	Match *match;
	NSData *data;
	
	NSLog(@"Storing ConflictsSet in NSUserDefaultPrefs...");
	
	// Convierto el NSSet de NSSets en un NSArray de NSArrays
	// Hay 'n' sets, cada uno con un set en el que hay matches.
	for ( subset in conflictsSet ) 	{
		//NSLog(@"      : adding subset.");
		NSMutableArray *subarray = [[NSMutableArray alloc] init];
		// Cada subset contiene una bolsa (bag) de Matches, que debo meter en un array
		for ( match in subset ) 		{
			[subarray addObject:match];
			//NSLog(@"        -> adding: %@", match.categoryMatched);
		}
		[array addObject:subarray];
		[subarray release];
	}
	
	data = [NSKeyedArchiver archivedDataWithRootObject:array];
	[prefs removeObjectForKey:@"conflicts"];
	[prefs setObject:data forKey:@"conflicts"];	
	[data release];

	[prefs synchronize];
	
	NSLog(@"DONE!");
	return 0;
}

/* 
 Esta funcion recupera las estructuras que solucionan los conflictos de los
 ficheros de NSUserDefaults.
 */
-(NSMutableSet *)readFromPrefs
{
	NSMutableSet *conflictsSet = [[NSMutableSet alloc] init];
	NSMutableArray *array;
	NSMutableArray *subarray = [[NSMutableArray alloc] init];
	NSData *data;
	Match *match;
	
	NSLog(@"Recovering ConflictsSet from NSUserDefaults...");
	
	data  = [prefs objectForKey:@"conflicts"];
	array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	
	for ( subarray in array ) 
	{
		//NSLog(@"      : extracting set");
		NSMutableSet *subset = [[NSMutableSet alloc] init];
		
		for ( match in subarray ) 
		{
			[subset addObject:match];
			//NSLog(@"        -> extracting: %@", match.categoryMatched);
		}
		
		[conflictsSet addObject:subset];
		[subset release];
	}
	
	NSLog(@"DONE!");
	return conflictsSet;
}

/*
 * Una funcion para buscar si existe una categoria con un nombre dado.
 */  
- (int) searchCategory:(NSString *)category
{
	NSLog(@"Searching category %@ ...", category);
	// Compruebo que no exista ya una categoria igual.
	for(id key in diccionario) 
	{
		// Si es así, devuelvo 0, que significa exito
		if ( [category caseInsensitiveCompare:key] == 0) {
			NSLog(@"  MATCH -> %@", key);
			return (0);
		}
	}
	// SI no, devuelvo error.
	NSLog(@"ERROR: Couldn't find category %@.", category);	
	return 1;
}


/*
 * Una funcion para crear una nueva categoria vacia
 */  
- (int) createCategory:(NSString *)newCategory
{
	//NSMutableDictionary *tags = [[NSMutableArray alloc] init];
	NSMutableDictionary *tags = [[NSMutableDictionary alloc] init];
	
	// Compruebo que no exista ya una categoria igual.
	for(id key in diccionario) 
	{
		// Si es así, devuelvo error
		if ( [newCategory caseInsensitiveCompare:key] == 0) {
			NSLog(@"  Error: Couldn't create category. Already exist one");
			return (-1);
		}
	}
	// SI no, continuo.
	// Añado el nombre al array de categorias
	[diccionario setObject:tags forKey:newCategory];
	NSLog(@"Creating category %@", newCategory);
	
	return 0;
}

/*
 Una funcion para cargarme una categoría entera con todo dentro.
 */
-(int) removeCategory:(NSString *)category
{
	NSLog(@"Removing key %@ from dictionary ...", category);
	// Compruebo si existe la categoria.
	for(id key in diccionario)	{
		if ( [category caseInsensitiveCompare:key] == 0) {
			[diccionario removeObjectForKey:category];
			NSLog(@"  REMOVED!");
			return 0;
		}
	}
	NSLog(@"  ERROR: Couldn't remove category!");
	return 1;
}


/*
 Una funcion para renombrar una categoría.
 */
-(int) renameCategory:(NSString *)oldCategory: (NSString *)newCategory
{
	NSLog(@"Renaming category %@ to %@ ...", oldCategory, newCategory);
	// Compruebo si existe la categoria.
	for(id key in diccionario)	{
		if ( [oldCategory caseInsensitiveCompare:key] == 0) {
			
			id value = [diccionario objectForKey:oldCategory];
			[diccionario setObject:value forKey:newCategory];
			[diccionario removeObjectForKey:oldCategory];
			
			NSLog(@"  RENAMED!");
			return 0;
		}
	}
	NSLog(@"  ERROR: Couldn't rename category!");
	return 1;
}

/*
 Una funcion para buscar un tag determinado.
 */
-(int) searchTag:(NSString *)tag
{
	NSMutableArray *tags;
	NSLog(@"Searching tag %@ ...", tag);
	// Compruebo si existe la categoria.
	for(id key in diccionario)	{
		tags = [diccionario objectForKey:key];
		for (int i=0;i<tags.count; i++) {
			if ( ([[tags objectAtIndex:i] caseInsensitiveCompare:tag]) == 0 ) {
				NSLog(@"  FOUND tag %@ within category %@!", tag, key);
				return 0;
			}
		}
	}
	NSLog(@"  ERROR: Couldn't find tag!");
	return 1;
}

/*
 Una funcion mas intrusiva que la de "searchTag" porque esta busca 
 ocurrencias de la cadena de busqueda dentro de la cadena que se le
 pasa como argumento. Más util para el caso que nos ocupa.
 Lo que devuelve esta funcion es el array con los nombres de las categorias o "nil" 
 si no encuentra nada.
 */
-(NSSet *) matchTag:(NSString *)inputString
{
	NSMutableArray *tags;
	NSMutableArray *matchingCategories = [[NSMutableArray alloc] init];
	NSMutableSet *matchesFound = [[NSMutableSet alloc] init];
	Match *match = nil;
	BOOL isThisCategoryMatched = FALSE;
	
	// Para cada categoria busco ocurrencias de sus tags dentro de la cadena de busqueda.
	for(id key in diccionario) 
	{
		// Cojo los tags de la categoria que toca en el loop
		tags = [diccionario objectForKey:key];
		NSRange range;
		isThisCategoryMatched = FALSE;
		
		// Los recorro todos...
		for (int i=0; i<tags.count; i++) 
		{
			// Busco este tag entre la entrada del banco.
			range = [inputString rangeOfString:[tags objectAtIndex:i] options:NSCaseInsensitiveSearch];

			// Si he encontrado la subcadena...
			if (range.location != NSNotFound) 
			{
				// Meto la categoria en un array.
				[matchingCategories addObject:key];
				
				// Experimental
				if (match == nil) {
					match = [[Match alloc] init];
					match.categoryMatched = key;
				}
				[match.tagsMatched addObject:[tags objectAtIndex:i]];      // Push the tag onto the array.
				if (!isThisCategoryMatched) isThisCategoryMatched = TRUE;  // Set the flag.
			}
		}
		if (isThisCategoryMatched) 
		{
			[matchesFound addObject:match];
			[match release];
			match = nil;
		}
	}
	
	// Intento ordenar el array final por numero de ocurrencias.
	// Array with distinct elements only, sorted by their repeat count
	// NSCountedSet *countedSet = [[[NSCountedSet alloc] initWithArray:matchingCategories] autorelease];
	// NSArray *distinctArray = [[countedSet allObjects] sortedArrayUsingFunction:countedSort context:countedSet];
		
	return matchesFound;
}

/*
 Una funcion mas intrusiva que la de "searchTag" porque esta busca 
 ocurrencias de la cadena de busqueda dentro de la cadena que se le
 pasa como argumento. Más util para el caso que nos ocupa.
 Lo que devuelve esta funcion es el array con los nombres de las categorias o "nil" 
 si no encuentra nada.
 */
-(NSArray *) matchTag_old:(NSString *)inputString
{
	NSMutableArray *tags;
	NSMutableArray *matchingCategories = [[NSMutableArray alloc] init];
	NSMutableArray *matchesFound = [[NSMutableArray alloc] init];
	Match *match = nil;
	BOOL isThisCategoryMatched = FALSE;
	
	// Para cada categoria busco ocurrencias de sus tags dentro de la cadena de busqueda.
	for(id key in diccionario) 
	{
		// Cojo los tags de la categoria que toca en el loop
		tags = [diccionario objectForKey:key];
		NSRange range;
		isThisCategoryMatched = FALSE;
		
		// Los recorro todos...
		for (int i=0; i<tags.count; i++) 
		{
			// Busco este tag entre la entrada del banco.
			range = [inputString rangeOfString:[tags objectAtIndex:i] options:NSCaseInsensitiveSearch];
			
			// Si he encontrado la subcadena...
			if (range.location != NSNotFound) 
			{
				// Meto la categoria en un array.
				[matchingCategories addObject:key];
				
				// Experimental
				if (match == nil) {
					match = [[Match alloc] init];
					match.categoryMatched = key;
				}
				[match.tagsMatched addObject:[tags objectAtIndex:i]];      // Push the tag onto the array.
				if (!isThisCategoryMatched) isThisCategoryMatched = TRUE;  // Set the flag.
			}
		}
		if (isThisCategoryMatched) 
		{
			[matchesFound addObject:match];
			[match release];
			match = nil;
		}
	}
	
	// Intento ordenar el array final por numero de ocurrencias.
	// Array with distinct elements only, sorted by their repeat count
	// NSCountedSet *countedSet = [[[NSCountedSet alloc] initWithArray:matchingCategories] autorelease];
	// NSArray *distinctArray = [[countedSet allObjects] sortedArrayUsingFunction:countedSort context:countedSet];
	
	return matchesFound;
}


/*
 Una funcion para cargarme un tag de una categoría.
 */
-(int) removeTag:(NSString *)tag: (NSString*)category
{
	NSMutableArray *tags;
	NSLog(@"Removing tag %@ from category %@ ...", tag, category);
	// Compruebo si existe la categoria.
	for(id key in diccionario)	{
		if ( [category caseInsensitiveCompare:key] == 0) {
			tags = [diccionario objectForKey:key];
			for (int i=0;i<tags.count; i++) {
				if ( ([[tags objectAtIndex:i] caseInsensitiveCompare:tag]) == 0 ) {
					[tags removeObjectAtIndex:i];
					NSLog(@"  REMOVED!");
					return 0;
				}
			}
		}
	}
	NSLog(@"  ERROR: Couldn't remove tag!");
	return 1;
}


/*
 Una funcion para renombrar un tag de una categoría.
 */
-(int) renameTag:(NSString *)tag: (NSString*)category: (NSString *)newTag
{
	NSMutableArray *tags;
	NSLog(@"Renaming tag %@ from category %@ to %@...", tag, category, newTag);
	// Compruebo si existe la categoria.
	for(id key in diccionario)	{
		if ( [category caseInsensitiveCompare:key] == 0) {
			tags = [diccionario objectForKey:key];
			for (int i=0;i<tags.count; i++) {
				if ( ([[tags objectAtIndex:i] caseInsensitiveCompare:tag]) == 0 ) {
					[tags replaceObjectAtIndex:i withObject:newTag];
					NSLog(@"  RENAMED!");
					return 0;
				}
			}
		}
	}
	NSLog(@"  ERROR: Couldn't rename tag!");
	return 1;
}


/*
 Una funcion para añadir un tag a una categoria.
 Miro si existe la categoria
 Miro si no existe el tag
 Añado el tag.
 Devuelvo un cero.
 Error
 Error
 */
- (int) addTagToCategory:(NSString *)newTag: (NSString *)targetCategory
{
	NSMutableArray *categoryTags;
	
	if ([self searchCategory:targetCategory] == 0) {
		if ((categoryTags = [diccionario objectForKey:targetCategory]) == nil) {
			NSLog(@"  Error: Couldn't find category %@",targetCategory);
			return 1;
		}
		NSLog(@"Adding tag %@ to category %@", newTag, targetCategory);
		[categoryTags addObject:newTag];
		return 0;
	}
	NSLog(@"  ERROR: Couldn't add tag!");
	return 2;
}

/*
 * Una funcion para mostrar todas las categorias y sus tags por pantalla.
 */
- (void) listCategories
{
	if ( [diccionario count] == 0) {
		NSLog(@"WARNING: Empty dictionary");
		return;
	}
	
	NSLog(@"-------------------------------");
	NSLog(@"LISTING ALL CATEGORIES and TAGS");
	NSLog(@"-------------------------------");
	NSMutableArray *tags = [[NSMutableArray alloc] init];
	
	for(id key in diccionario) 
	{
		NSLog(@"%@", key);
		tags = [diccionario objectForKey:key];
		for (int i=0; i<tags.count; i++) {
			NSLog(@"-- %@", [tags objectAtIndex:i]);
		}
	}
}

/*
 * Una funcion para retornar en un array todos los nombres de las categorias.
 */
- (NSMutableArray *) getCategoryNames
{
	if ( [diccionario count] == 0) {
		NSLog(@"WARNING: Empty dictionary");
		return nil;
	}
	
	NSMutableArray *names = [[[NSMutableArray alloc] init] retain];
	for(id key in diccionario) 
	{
		[names addObject:key];
	}
	NSLog(@"getCategoryNames: Returning %lu categories in array", [names count]);
	return names;
}


@end
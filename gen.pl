use XML::LibXML;

#WARNING: very messy

my $xml_file = 'gl.xml';
my $parser = XML::LibXML->new();
my $document = $parser->parse_file($xml_file);

my @enum_elements = $document->findnodes('//enums');

my %seen_constants;

foreach my $enum_element (@enum_elements) {
    my @enum_values = $enum_element->findnodes('./enum');

    foreach my $enum_value (@enum_values) {
        my $value = $enum_value->getAttribute('value');
        my $name = $enum_value->getAttribute('name');

        # Skip constants that have been seen before
        if (exists $seen_constants{$name} && $seen_constants{$name} == $value) {
            next;
        }

        # Record this constant and its value
        $seen_constants{$name} = $value;

        # Generate the constant-like definition in the "hare" language syntax
        my $constant_declaration = "export def $name = $value;";
        
        # Print or store the generated constant declaration
        print "$constant_declaration\n";
    }
}

my %type_mapping = (
    'khronos_uint8_t' => 'u8',
    'khronos_int8_t'  => 'i8',
    'khronos_uint16_t' => 'u16',
    'khronos_int16_t'  => 'i16',
    'khronos_uint32_t' => 'u32',
    'khronos_int32_t'  => 'i32',
    'khronos_uint64_t' => 'u64',
    'khronos_int64_t'  => 'i64',
    'khronos_ssize_t'  => 'u32',
    'khronos_intptr_t' => '*int',
    'void *' => '*void',
    'unsigned int' => 'u32'
);

my @type_elements = $document->findnodes('//types/type');


foreach my $type_element (@type_elements) {
    my $name = $type_element->findvalue('./name');
    my $value = $type_element->findvalue('text()'); # Extract text content

    next unless $name && $value;

    # Skip specific types
    next if $value =~ /^#ifdef|^\s*#include/;
    next if $value =~ /^struct\s+/;
    next if $value =~ /^void\s+\(\s*\*\s*\)\s*\(\s*\w*\s*\)\s*;/;

    # Skip GLDEBUGPROC
    next if $name =~ /GLDEBUGPROC/;
    next if $name =~ /GLsync/;
    next if $name =~ /GLVULKANPROCNV/;
    next if $name =~ /struct/;

    # Convert data types
    $value =~ s/typedef //g;  # Remove 'typedef' keyword
    $value =~ s/unsigned int/u32/g;
    $value =~ s/unsigned char/u8/g;
    $value =~ s/unsigned short/u16/g;
    $value =~ s/void \*/nullable *void/g;
    

    $value =~ s/typedef //g;  # Remove 'typedef' keyword
    $value =~ s/\bkhronos_//g;
    $value =~ s/\b_t//g;


    if (exists $type_mapping{$value}) {
        $value = $type_mapping{$value};
    }

    $value =~ s/uint8_t/u8/g;
    $value =~ s/int8_t/i8/g;
    $value =~ s/char/i8/g;
    $value =~ s/uint16_t/u16/g;
    $value =~ s/intptr_t/*int/g;
    $value =~ s/float_t/f32/g;
    $value =~ s/int32_t/i32/g;
    $value =~ s/int64_t/i64/g;
    $value =~ s/ssize_t/u64/g;
    $value =~ s/int63_t/i16/g;
    $value =~ s/int/i32/g; 
    $value =~ s/i3216_t/i16/g;
    $value =~ s/ui64/u64/g;
    $value =~ s/GLi32ptr/GLintptr/g;
    $value =~ s/double/f64/g;
    $value =~ s/float/f32/g;

    
    # Generate the constant-like definition in the hare language syntax
    my $constant_declaration = "export type $name = $value";
    
    # Print or store the generated constant declaration
    print "$constant_declaration\n";
}


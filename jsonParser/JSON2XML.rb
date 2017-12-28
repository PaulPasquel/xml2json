#
# UNED, MIISS: Paul Pasquel, Octubre-2017
# 
# 
# Clase y programa principal para integrar los siguientes pasos:
#    1. Cargar el archivo a una variable en memoria (arreglo)
#    2. Parsear el contenido del archivo para obtener una representacion de un objet JSONModel.JObject
#    3. Generar el resultado
#

require 'strscan'          # Cargar StringScanner
require 'JSONModel'        # Cargar Modelo JSON
require 'JSONParser'       # Cargar Parser de string a representacion JSON 

class JSON2XML
  include JSONParser

  attr_reader :memoryFile
  attr_reader :jsonObject
  attr_reader :resultXML
  
  def initialize()
      @resultXML = []
      @memoryFile = []  
  end

  #
  # Program principal, consolida los pasos
  #
  def parse(inFile, outFile)
      loadFile(inFile)                        # Carga archivo a memoria
      str = @memoryFile.join("")          
      jsonParser = Parser.new(str)            # Generar el modelo a partir de la cadena JSON
      @resultXML<<"<xml>" 
      convertToXML(jsonParser.JSONobject,0)     # Convertir el objeto JSON en XML
      @resultXML<<"</xml>" 
      
      printToConsole()                        # Mostrar resultado en la consola              
              
      writeToFile(outFile)                    # Escribir el resultado en el archivo de salida
  end

  def repeat(text, n)
    text = text * n
  end  
    
  #
  # Cargar archivo en memoria como un arreglo
  #
  def loadFile(inFile)
      counter = 0      
      File.open(inFile, "r") do |infile|               # Abre el archivo
           while (line = infile.gets)                    # Obtiene cada linea y la carga en un arreglo
                @memoryFile[counter] = line
                counter = counter + 1
           end
      end         
  end
  

  #
  # Convert JSONModel.JObject to XML representation
  #
  def convertToXML(o,level)
    offset = repeat(" ", level) 
    level += 1
    if o.instance_of?(JSONModel::Pair) then                  # Si el elemento un es par (Pair)
       if o.value.instance_of?(JSONModel::JObject) then          # Si el valor del par (Pair.value) es un objeto 
         @resultXML<<offset+"<#{o.key}>"                                  # la clave se transforma en un tag XML  
         convertToXML(o.value, level)                                     # se invoca a imprimir el contenido
         @resultXML<<offset+"</#{o.key}>"                                 # cierra el tag XML 
       elsif o.value.kind_of?(Array)                             # Si el valor es un arreglo  
         i = 1
         list = o.value                                          # Por cada elemento en la lista 
         for i in 0..(list.length-1)
           pos = i + 1         
           @resultXML<<offset+"<#{o.key} id=\"#{pos}\">"                  # usando el key del emento se crea un tag, anadiendo numeracion  
           convertToXML(list[i], level)                                   # imprimir el contenido
           @resultXML<<offset+"</#{o.key}>"                               # cierra el tag XML 
           i = i + 1
         end
       else                                                 # Caso contrario, es un valor simple
         @resultXML<<offset+"<#{o.key}>"
         @resultXML<<offset+o.value  
         @resultXML<<offset+"</#{o.key}>"
       end  
    elsif o.instance_of?(JSONModel::JObject) then           # Si es un JSONModel.Object     
       o.pairList.each{|el|                                    # imprimir cada par (Pair) del objeto    
         convertToXML(el,level)    
       }
    else                                                    # Caso contrario imprimir el valor simple
       @resultXML<<offset+o                              
    end  
  end
  
  #
  # Enviar la salida a un archivo
  #
  def writeToFile(outputFile)
    File.open(outputFile, "w+") do |f|
        @resultXML.each { |line| f.puts(line) }
    end    
  end     

  #
  # Mostrar el resultado en la consola
  #
  def printToConsole
    @resultXML.each { |line| puts line}
  end    
  
end

#
#  Ejecutar logica de transformacion
#

if ARGV == nil || ARGV.length != 2
   puts "usage:"
   puts "ruby -I. JSON2XML.rb infile outfile"
   return
end

inFile = ARGV[0]
outFile= ARGV[1]

json2xml = JSON2XML.new()
json2xml.parse(inFile, outFile)




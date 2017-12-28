#
# UNED, MIISS: Paul Pasquel, Octubre-2017
#
# Es modulo contiene la logica que permite transformar una cadena de caracteres JSON en
# el modelo de datos correspondiente (JSONModel.JObject)

module JSONParser

  class Parser
    include JSONModel
    attr_reader :JSONobject
    
    #
    # inicializa la cadena, y procede a obtener la representacion en el Modelo Objetos definido
    #
    def initialize(str) 
      @buffer = StringScanner.new(str)
      @JSONobject = getObject()    
    end 
  
    
    #  
    # Verificar el siguiente caracter corresponda al esperado
    #
    def checkChar(shouldbe)
      skip_spaces
      ch = @buffer.peek(1) 
      if ch != shouldbe
        raise_error(shouldbe) 
      end  
    end  
      
  
    #
    # Obtener un clave (Pair.key)
    #    
    def getKey()
      # Obtener cualquier cadena encerrada en comillas dobles
      key = @buffer.scan_until(/("[^"]*")/) 
      if key == nil then
         raise_error("\"")                 # Se espera un " como inicio de un Pair.key
      end   
      key = key.gsub(/\s+/, "")            # Limpiar espacios obtenidos
      if key[1] == "\"" then               # cortar las comillas dobles del resultado
         key = key[2..-2]                  
      else   
         key = key[1..-2]                  
      end  
    end  
  
    #
    # Obtener Arreglo
    #
    def getArray()
      value = []
      checkChar("[")                    # el arreglo debe iniciar con [
      while(1==1)                       # hacer hasta encontrar ]  
         @buffer.getch
         skip_spaces
         if current() == "{"            # el arreglo contiene uno o mas objetos
           value << getObject()
         elsif current() == "["         # el arreglo contiene otros arreglos 
           value << getArray()   
         else
           value << getSingleValue()    # no es un objeto o arreglo, entonces es un valor simple
         end  
         skip_spaces
         break if current() == "]"      # al encontrar ], se termina el loop 
         if current() != ","           
           raise_error(", o ]")             # los elementos en un arreglo estan separados por un ,
         end   
      end
      @buffer.getch
      return value                      # devolver el arreglo  
    end
    
    #  
    # Obtener un valor (Object, String, Number, Boolean, Array)
    #       
    def getValue()
        skip_spaces
        if current() == "{"            # el valor es un objeto
          return getObject()
        elsif current() == "["         # el valor es un arreglo
          return getArray()
        else                           # el valor es un valor simple
          return getSingleValue()       
        end   
    end

    #     
    # Obtener valor simple:
    #   - Cadena de caracteres (cualquier cosa que se encierre en comillas dobles)
    #   - Numero decimal, opcionalmente con el punto como separador decimal
    #   - Valor boleano true o false
    #  TODO: improve number for accepting e/E
    #    
    def getSingleValue()
       value = @buffer.scan_until(/(("[^"]*")|(-)?(([0-9]+.{1}\d+)|([0-9]+))|\b(true|false){1}\b)/)
       if value == nil then
         raise_error("'Number, String or Boolean'")
       end   
       value = value
    end  
    
    #
    # utilidad, para obtener el caracter actual
    #
    def current()
        return @buffer.peek(1)
    end  
    
    #
    # Obtener un objeto
    #
    def getObject()
       object = JObject.new()
       checkChar("{")                      # Siempre inicia con {
       @buffer.getch
       skip_spaces
       if current() == "}"                 # Objeto vacio ?
          @buffer.getch
          return object 
       end
       
       while(1==1)                         # hasta no encontrar } 
          key = getKey()                   # obtener la clave (Pair.key)
          pair = Pair.new(key)
          checkChar(":")                   # despues una clave debe estar :  
          @buffer.getch
          pair.value = getValue()          # obtener el valor   
          object.pairList<<pair            # agregar el par (Pair) al objeto
          skip_spaces
          break if current() == "}"        # si se encuentra }, fin del loop
          if current() != ","
             raise_error(", o }")              # los valores se separan por ,
          end   
       end     
       @buffer.getch
       return object       
    end
  
    #
    # Centraliza la generacion del mensaje de error en caso de formato erroneo
    #
    def raise_error(expected_value)
      c = current()
      texto = " requerido=> #{expected_value} encontro=> #{c}"
       raise "Formato erroneo #{texto} posicion=> #{@buffer.pos}"
    end
    
    #
    # Saltar cualquier caracter considerado espacio en blanco
    #
    def skip_spaces 
      @buffer.skip(/\s+/) 
    end       
  end
end
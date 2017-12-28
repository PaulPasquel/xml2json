#
# UNED, MIISS: Paul Pasquel, Octubre-2017
#
# Este modulo contiene la representacion de los elementos JSON como objetos (Modelo)
#
# De acuerdo a los siguientes lineamientos:
#    1. Un objeto Json (JObject) contiene ninguno, uno o mas pares de valores (pairList)
#    2. Cada par (Pair) esta compuesto de una clave (key) y un valor (value) 
#    3. Un valor (Pair.value) le corresponde:
#          - Un string (cualquier cadena de caracteres encerrado en comillas dobles)
#          - Un numero (puede incluir el punto decimal)
#          - Un Arreglo
#    4. Un Arreglo puede corresponder a ninguno, uno o mas valores (Pair.value)
#     
module JSONModel
  
  # Un objeto esta compuesto de uno o mas pares
  class JObject
    attr_accessor :pairList
    def initialize
       @pairList = []
    end  
  end
  
  # Un par se compone de una clave y un valor
  class Pair
      attr_accessor :key
      attr_accessor :value # un valor puede ser un objeto, string (numero, booleano), arreglo
      def initialize(key)
        @key = key
      end
  end 
  
end
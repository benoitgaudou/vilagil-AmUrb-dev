class Model:

    def __init__(self):
        self.__data = {}

    def __updateData__(self,dataId,dataValue):
        self.__data[dataId] = dataValue

    def __getData__(self,dataId):
        return self.__data[dataId]
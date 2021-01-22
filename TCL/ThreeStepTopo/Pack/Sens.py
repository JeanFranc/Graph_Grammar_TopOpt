import sys


def MesureComplexity(filePath):

    import numpy as np

    # Reads the file at path1.

    with open(filePath,"r") as f:
        Lines = f.readlines()
        
        i = 0
        splitted_line = Lines[0].split(' ')
        ll = len(splitted_line)
        
        Sensitivity_Matrix = np.empty((0,ll-3), float)
        
        for line in Lines:
            line = line.rstrip()
            splitted_line = line.split(' ')
            goodList = np.array(splitted_line[3:])
            goodList = np.asfarray(goodList,float)

            Sensitivity_Matrix = np.append(Sensitivity_Matrix, [goodList], axis=0)
            
    # Normalize for mass.

    Norm_Sens = Sensitivity_Matrix

    for i in range(0, len(Norm_Sens)):
        mass_Sens = Sensitivity_Matrix[i][0]
        line = Sensitivity_Matrix[i]
        
        for j in range(1, len(line)):
            Norm_Sens[i][j] = Sensitivity_Matrix[i][j] / mass_Sens

    Norm_Sens = np.delete(Norm_Sens,0,1)
            
    # Normalize per Functions.

    for i in range(Norm_Sens.shape[1]):
        func_Max = np.amax(abs(Norm_Sens[:,i]))
        
        for j in range(0, len(Norm_Sens[:,i])):
            Norm_Sens[j,i] = Norm_Sens[j,i] / func_Max
            
    # Calculate the coupling between each functions.

    n = Norm_Sens.shape[1]
    T = np.empty((0,1),float)

    for i in range(0,n-1):
        for j in range(i+1, n):
            col1 = Norm_Sens[:,i]
            col2 = Norm_Sens[:,j]
        
            CkiCkj = sum(abs(col1*col2))
            Cki2   = sum(np.square(col1))
            Ckj2   = sum(np.square(col2))
            
            TT     = np.sqrt(abs(1 - np.square(CkiCkj)/Cki2/Ckj2))
            
            T = np.append(T,[TT])
            
    # Quantify the coupling.
    QT = 1 - np.quantile(T,0.25)
    
    print(QT)

    return QT
    
if __name__ == '__main__':
    MesureComplexity(*sys.argv[1:])
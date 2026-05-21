import numpy as np

class BJT:
    def __init__(self, nodeBase, nodeCollector, nodeEmitter, Is, beta, m):
        self.nodeBase = nodeBase
        self.nodeCollector = nodeCollector
        self.nodeEmitter = nodeEmitter
        self.Is = Is
        self.beta = beta
        self.m = m

    def getGMatrix(self, V_BE, V_BC):
        V_BE = np.clip(V_BE, -0.8, 1.0) # Avoid unfortunate situations
        V_BC = np.clip(V_BC, -0.8, 1.0) # Avoid unfortunate situations
        V_T = 0.025

        I_BE = self.Is * (np.exp(V_BE / (self.m * V_T)) - 1)
        G_BE = self.Is / (self.m * V_T) * np.exp(V_BE / (self.m * V_T))

        if V_BE < -0.7: G_BE = 1e-9            # Avoid unfortunate situations
        if V_BE >  0.8: G_BE = max(G_BE, 0.1)  # Avoid unfortunate situations

        I_BC = self.Is * (np.exp(V_BC / (self.m * V_T)) - 1)
        G_BC = self.Is / (self.m * V_T) * np.exp(V_BC / (self.m * V_T))

        if V_BC < -0.7: G_BC = 1e-9            # Avoid unfortunate situations
        if V_BC >  0.8: G_BC = max(G_BC, 0.1)  # Avoid unfortunate situations

        I_E = -(self.beta / (self.beta + 1)) * I_BE + 0.5 * I_BC
        I_B = (1 - (self.beta / (self.beta + 1))) * I_BE + 0.5 * I_BC
        dIE_dVBE = -(self.beta / (self.beta + 1)) * G_BE
        dIE_dVBC = 0.5 * G_BC
        dIB_dVBE = (1 - (self.beta / (self.beta + 1))) * G_BE
        dIB_dVBC = 0.5 * G_BC

        matrixSize = max(self.nodeBase, self.nodeCollector, self.nodeEmitter) + 1
        GMatrix = np.zeros((matrixSize, matrixSize))

        GMatrix[self.nodeBase][self.nodeBase]           += dIB_dVBE + dIB_dVBC
        GMatrix[self.nodeBase][self.nodeEmitter]        -= dIB_dVBE
        GMatrix[self.nodeBase][self.nodeCollector]      -= dIB_dVBC

        GMatrix[self.nodeEmitter][self.nodeBase]        += dIE_dVBE
        GMatrix[self.nodeEmitter][self.nodeEmitter]     -= dIE_dVBE
        GMatrix[self.nodeEmitter][self.nodeCollector]   += dIE_dVBC

        return GMatrix

    def getIMatrix(self, V_BE, V_BC):
        V_BE = np.clip(V_BE, -0.8, 1.0)  # Avoid unfortunate situations
        V_BC = np.clip(V_BC, -0.8, 1.0)  # Avoid unfortunate situations
        V_T = 0.025

        I_BE = self.Is * (np.exp(V_BE / (self.m * V_T)) - 1)
        G_BE = self.Is / (self.m * V_T) * np.exp(V_BE / (self.m * V_T))

        if V_BE < -0.7: G_BE = 1e-9  # Avoid unfortunate situations
        if V_BE > 0.8: G_BE = max(G_BE, 0.1)  # Avoid unfortunate situations

        I_BC = self.Is * (np.exp(V_BC / (self.m * V_T)) - 1)
        G_BC = self.Is / (self.m * V_T) * np.exp(V_BC / (self.m * V_T))

        if V_BC < -0.7: G_BC = 1e-9  # Avoid unfortunate situations
        if V_BC > 0.8: G_BC = max(G_BC, 0.1)  # Avoid unfortunate situations

        I_E = -(self.beta / (self.beta + 1)) * I_BE + 0.5 * I_BC
        I_B = (1 - (self.beta / (self.beta + 1))) * I_BE + 0.5 * I_BC
        dIE_dVBE = -(self.beta / (self.beta + 1)) * G_BE
        dIE_dVBC = 0.5 * G_BC
        dIB_dVBE = (1 - (self.beta / (self.beta + 1))) * G_BE
        dIB_dVBC = 0.5 * G_BC

        matrixSize = max(self.nodeBase, self.nodeCollector, self.nodeEmitter) + 1
        VMatrix = np.zeros(matrixSize)

        VMatrix[self.nodeBase]      -= I_B - dIB_dVBE * V_BE - dIB_dVBC * V_BC
        VMatrix[self.nodeEmitter]   -= I_E - dIE_dVBE * V_BE - dIE_dVBC * V_BC

        return VMatrix

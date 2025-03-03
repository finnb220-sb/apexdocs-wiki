public with sharing class VCC_APIService {
    public static VCC_BridgProxy Bridg = new VCC_BridgProxy();

    //public static VCC_MPIProxy MPI = new VCC_MPIProxy();

    public static VCC_VdifProxy VDIF = new VCC_VdifProxy();

    public static void debugMode(Boolean isDebug) {
        Bridg.debugMode(isDebug);
        VDIF.debugMode(isDebug);
    }

    public static void trainingMode(Boolean isTraining) {
        Bridg.trainingMode(isTraining);
        VDIF.trainingMode(isTraining);
    }
}

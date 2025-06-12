procedure CreateKeepoutLineAroundBoard;
var
    Board       : IPCB_Board;
    Contour     : IPCB_Region;
    Iterator    : IPCB_PrimitiveIterator;
    Track       : IPCB_Track;
    Keepout     : IPCB_Track;
    LineWidth   : TCoord;
    Vertex1, Vertex2: TCoordPoint;
begin
    // Ottieni la scheda PCB corrente
    Board := PCBServer.GetCurrentPCBBoard;
    if Board = nil then exit;

    // Imposta la larghezza della linea a 1.5 mm (convertito in unità interne, tipicamente 1 mm = 10000 unità interne)
    LineWidth := MMsToCoord(1.5);

    // Crea un iteratore per il contorno della scheda
    Iterator := Board.BoardIterator_Create;
    Iterator.AddFilter_ObjectSet(MkSet(eRegionObject));
    Iterator.AddFilter_Method(eProcessAll);

    // Itera attraverso tutti gli oggetti di contorno della scheda
    Contour := Iterator.FirstPCBObject as IPCB_Region;
    while Contour <> nil do
    begin
        // Itera attraverso i segmenti del contorno
        Track := Contour.FirstPrimitive as IPCB_Track;
        while Track <> nil do
        begin
            // Crea una nuova traccia di keepout con larghezza specificata
            Keepout := PCBServer.PCBObjectFactory(eTrackObject, eNoDimension, eCreate_Default);
            Keepout.X1 := Track.X1;
            Keepout.Y1 := Track.Y1;
            Keepout.X2 := Track.X2;
            Keepout.Y2 := Track.Y2;
            Keepout.Width := LineWidth;
            Keepout.Layer := eKeepOutLayer;

            // Aggiungi la traccia di keepout alla scheda
            Board.AddPCBObject(Keepout);

            // Passa al segmento successivo nel contorno
            Track := Contour.NextPrimitive as IPCB_Track;
        end;

        // Passa all'oggetto successivo nel contorno
        Contour := Iterator.NextPCBObject as IPCB_Region;
    end;

    // Distruggi l'iteratore
    Board.BoardIterator_Destroy(Iterator);

    // Aggiorna la vista PCB
    PCBServer.PostProcess;

end;

begin
    CreateKeepoutLineAroundBoard;
end.


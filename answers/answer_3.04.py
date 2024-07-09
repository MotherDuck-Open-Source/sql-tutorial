# Without column renaming
(
    ibis.read_csv('birds.csv')
        .group_by('Species_Common_Name')
        .aggregate([_.Beak_Width.mean(), _.Beak_Depth.mean(), _.Beak_Length_Culmen.mean()])
)

# With column renaming
(
    ibis.read_csv('birds.csv')
        .group_by('Species_Common_Name')
        .aggregate(Avg_Beak_Width=_.Beak_Width.mean(), Avg_Beak_Depth=_.Beak_Depth.mean(), Avg_Beak_Length_Culmen=_.Beak_Length_Culmen.mean())
 )

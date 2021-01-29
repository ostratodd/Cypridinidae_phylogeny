#########################################
# Tree setup 
#########################################
install.packages("ape")
install.packages("corHMM")

library(corHMM)
library(ape)
library(phytools)

########## ASTRAL CONSTRAINED TREE ###################
# Assign correct tree topology to the variable tree
tree <- read.tree("FcC_smatrix.phy_concatmat_constrained_Astral-2.treefile")
tree$tip.label <- gsub("*_clean.fasta.transdecoder.pep", "", tree$tip.label)

# The following code is used to rotate particular branches so they are in
# the order I choose.
tree <- rotate(tree,48)

# Create an ultrametric tree with correlated model, output of chronos 
# needed to be rewritten using read.tree, then test for ultrametricity
chronotree <- chronos(tree, lambda=1, model = "relaxed")
ultratree <- read.tree(text=write.tree(chronotree))
is.ultrametric(ultratree)

########## CONCATENATED TREE ###################
# Assign correct tree topology to the variable tree
tree.concat <- read.tree("partition_modified.nex.treefile")
tree.concat$tip.label <- gsub("*_clean.fasta.transdecoder.pep", "", tree.concat$tip.label)

# This roots the tree at node
tree.concat <- root(tree, "Cylindroleberidinae")

# Create an ultrametric tree with correlated model, output of chronos 
# needed to be rewritten using read.tree, then test for ultrametricity
chronotree.concat <- chronos(tree.concat, lambda=1, model = "correlated")
ultratree.concat <- read.tree(text=write.tree(chronotree.concat))
is.ultrametric(ultratree.concat)

########################################
# Ancestral state reconstruction 
########################################

# Pull the data matrix of interest into R
lum_data <- read.table("character_matrix_luminescence_edited_biolum.tab",stringsAsFactors=FALSE)

# Change any spaces into underscores for species names, then generate a vector with 
# the appropriate feeding data where the names are set to the species names

lum_data2 <- lum_data$V2
lum_data2 <- setNames(lum_data2, lum_data$V1)

datamatch <- match(names(lum_data2),ultratree$tip.label)
lum_data2 <- lum_data2[order(datamatch)]
lum_data2 <- data.frame(names(lum_data2),lum_data2)

########## ASTRAL CONSTRAINED TREE ###################
# corHMM runs
fitcorER <- rayDISC(ultratree, lum_data2, model="ER", node.states="marginal",state.recon="subsequently")
fitcorSYM <- rayDISC(ultratree, lum_data2, model="SYM", node.states="marginal",state.recon="subsequently")
fitcorARD <- rayDISC(ultratree, lum_data2, model="ARD", node.states="marginal",state.recon="subsequently")

# Log likelihood test
log.lik.test.ER <- data.frame(fitcorER$states)
log.lik.test.ER$stat <- abs(log(log.lik.test.ER$X0)-log(log.lik.test.ER$X1))
log.lik.test.ER$test <- log.lik.test.ER$stat >= 2
log.lik.test.ER$test <- gsub(TRUE,"*",log.lik.test.ER$test)
log.lik.test.ER$test <- gsub(FALSE,"",log.lik.test.ER$test)

# Set the colors for each set of labels for plotting
cols <- lum_data$V3
cols <- setNames(cols, lum_data$V1)
colors <- c("grey28", "deepskyblue", "blue3")

# Reordering the vector with the tip colors to match the taxon order in the tree
colsmatch <- match(names(cols),ultratree$tip.label)
cols2 <- cols[order(colsmatch)]

# Phylogeny plot full
setEPS()
postscript("ASR_ER_cypridindae_astral_biolum.eps")
plot.phylo(ultratree, label.offset=0.02, edge.width=2.5, cex=0.8)
tiplabels(pch=22, bg=cols2,cex=1.5)
nodelabels(pie=fitcorER$states,piecol=colors,cex=0.5)
nodelabels(log.lik.test.ER$test, col="purple", bg=NA,frame="none", adj=c(1.7,-0.1), cex=1.2)
dev.off()

########## CONCATENATED TREE ###################
# corHMM runs
fitcorER.c <- rayDISC(ultratree.concat, lum_data2, model="ER", node.states="marginal",state.recon="subsequently")
fitcorSYM.c <- rayDISC(ultratree.concat, lum_data2, model="SYM", node.states="marginal",state.recon="subsequently")
fitcorARD.c <- rayDISC(ultratree.concat, lum_data2, model="ARD", node.states="marginal",state.recon="subsequently")

# Log likelihood test
log.lik.test.ER.c <- data.frame(fitcorER.c$states)
log.lik.test.ER.c$stat <- abs(log(log.lik.test.ER.c$X0)-log(log.lik.test.ER.c$X1))
log.lik.test.ER.c$test <- log.lik.test.ER.c$stat >= 2
log.lik.test.ER.c$test <- gsub(TRUE,"*",log.lik.test.ER.c$test)
log.lik.test.ER.c$test <- gsub(FALSE,"",log.lik.test.ER.c$test)

# Reordering the vector with the tip colors to match the taxon order in the tree
colsmatch <- match(names(cols),ultratree$tip.label)
cols2 <- cols[order(colsmatch)]

# Phylogeny plot full
setEPS()
postscript("ASR_ER_cypridindae_concat_biolum.eps")
plot.phylo(ultratree.concat, label.offset=0.02, edge.width=2.5, cex=0.8)
tiplabels(pch=22, bg=cols2,cex=1.5)
nodelabels(pie=fitcorER.c$states,piecol=colors,cex=0.5)
nodelabels(log.lik.test.ER.c$test, col="purple", bg=NA,frame="none", adj=c(1.7,-0.1), cex=1.2)
dev.off()

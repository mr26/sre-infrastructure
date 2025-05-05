module "iam" {
    source = "../modules/iam"
}
module "networking" {
    source = "../modules/networking"

    lb_access_logs = module.infra.lb_access_logs

    alb_trust_store = module.infra.alb_trust_store
}

module "infra" {
    source = "../modules/infra" 

    private_subnet1 = module.networking.private_subnet1
    private_subnet2 = module.networking.private_subnet2 
    private_subnet3 = module.networking.private_subnet3

    main_vpc_id = module.networking.main_vpc_id

    cluster_role_arn = module.iam.cluster_role_arn
    node_role_arn = module.iam.node_role_arn

    eks_sg = module.networking.eks_sg
    api_cluster2_sec_grp = module.networking.api_cluster2_sec_grp
}
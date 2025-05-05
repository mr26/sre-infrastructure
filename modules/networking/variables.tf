variable "lb_access_logs" {
    description     =       "Access logs bucket for ALB."
    type            =       string

}

variable "alb_trust_store" {
    description     =       "Trust Store to verify client certificates."
    type            =       string

}
local module = {}

module.SENDINSTANTLY = true

module.MAIL = {
    CREATE = 0,
    SEND = 1,
    GET = 2,
    GET_UNREAD = 3,
    DELETE = 4,
    MARK_AS_READ = 5,
    MARK_AS_UNREAD = 6,
    GET_LIST = 7,
    GET_UNREAD_LIST = 8,
    GET_COUNT = 9,
    GET_UNREAD_COUNT = 10,
    GET_ATTACHMENT = 11,
    CLAIM_ATTACHMENT = 12
}

module.MAIL_STATUS = {
    UNKOWN = -1,
    CREATE = 0,
    UNREAD = 1,
    READ = 2,
    CLAIMED = 3,
    DELETED = 10,
}

module.STORENAME = {
    PlayerMailsStore = "Player_Mails",
    DomainMailsStore = "Domain_%s_Mails"
}

module.MAIL_EXPIRY_ADDITION = 1 * 60 * 60
module.MAX_EXPIRATION = 45 * 24 * 3600

module.DEFAULT_DOMAIN = "default"

return module
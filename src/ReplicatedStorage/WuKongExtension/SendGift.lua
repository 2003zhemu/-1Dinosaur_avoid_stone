local MailService = require(game.ReplicatedStorage.Packages.MailService)

return function(userId, _, vendorId, receiver)
	MailService.SendGiftMail(userId, receiver, {
		Type = "Gift",
		Id = vendorId,
		Count = 1,
	})
end

module VerifyWebhook
  extend ActiveSupport::Concern

  #used to authenicate in the event handler controller
  def get_payload_and_verify_webhook
    get_payload_request(request)
    verify_webhook_signature
  end

  # Saves the raw payload and converts the payload to JSON format
  def get_payload_request(request)
    # request.body is an IO or StringIO object
    # Rewind in case someone already read it
    request.body.rewind
    # The raw text of the body is required for webhook signature verification
    @payload_raw = request.body.read
    begin
      @payload = JSON.parse @payload_raw
    rescue => e
      fail  "Invalid JSON (#{e}): #{@payload_raw}"
    end
  end
  
  # Check X-Hub-Signature to confirm that this webhook was generated by
  # GitHub, and not a malicious third party.
  # GitHub uses the WEBHOOK_SECRET, registered to the GitHub App, to
  # create the hash signature sent in the `X-HUB-Signature` header of each
  # webhook. This code computes the expected hash signature and compares it to
  # the signature sent in the `X-HUB-Signature` header. If they don't match,
  # this request is an attack, and you should reject it. GitHub uses the HMAC
  # hexdigest to compute the signature. The `X-HUB-Signature` looks something
  # like this: "sha1=123456".
  # See https://developer.github.com/webhooks/securing/ for details.
  def verify_webhook_signature
    their_signature_header = request.env['HTTP_X_HUB_SIGNATURE'] || 'sha1='
    method, their_digest = their_signature_header.split('=')
    our_digest = OpenSSL::HMAC.hexdigest(method, ENV['GITHUB_WEBHOOK_SECRET'], @payload_raw)
    halt 401 unless their_digest == our_digest
  end

end